package com.wso2.metrics;

import org.apache.synapse.AbstractSynapseHandler;
import org.apache.synapse.MessageContext;
import org.apache.synapse.core.axis2.Axis2MessageContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

public class MetricsLogger extends AbstractSynapseHandler {

    private static final Logger log = LoggerFactory.getLogger("METRICS_LOGGER");

    @Override
    public boolean handleRequestInFlow(MessageContext messageContext) {
        messageContext.setProperty("cid", UUID.randomUUID());
        messageContext.setProperty("request-time", System.currentTimeMillis());
        return true;
    }

    @Override
    public boolean handleRequestOutFlow(MessageContext messageContext) {
        return true;
    }

    @Override
    public boolean handleResponseInFlow(MessageContext messageContext) {
        return true;
    }

    @Override
    public boolean handleResponseOutFlow(MessageContext messageContext) {
        long requestTime = (long) messageContext.getProperty("request-time");
        long responseTime = System.currentTimeMillis() - requestTime;
        String apiName = (String) messageContext.getProperty("SYNAPSE_REST_API");
        String resourcePath = (String) messageContext.getProperty("rest.url.pattern");
        String resourceMethod = (String) messageContext.getProperty("REST_METHOD");
        String statusCode = "NA";
        if (messageContext instanceof Axis2MessageContext) {
            Axis2MessageContext axis2MessageContext = (Axis2MessageContext) messageContext;
            Object statusObject = axis2MessageContext.getAxis2MessageContext().getProperty("HTTP_SC");
            if (statusObject != null) {
                statusCode = statusObject.toString();
            }
        }
        Axis2MessageContext axis2MessageContext = (Axis2MessageContext) messageContext;
        log.info("Response - " + messageContext.getProperty("cid") + " | " + apiName + " | " + resourcePath + " | " + resourceMethod + " | " + responseTime + " | " + statusCode);
        return true;
    }
}
