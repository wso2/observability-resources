# WSO2 Observability Solution

WSO2 observability solution provides monitoring and analytics capabilities for WSO2 products based on open source products and standards such as OpenSearch, Fluent-Bit, and Open Telemetry.

## Installation

### Kubernetes

#### Prerequisites

- **Kubernetes:**
 For trying out the solution, it is possible to set up a Kubernetes cluster locally using the [Rancher Desktop](https://docs.rancherdesktop.io/getting-started/installation) or the [Docker Desktop](https://www.docker.com/get-started/). Alternatively, any on-premise or cloud-based Kubernetes cluster such as [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service) or [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/) can be used. A Kubernetes cluster with at least 8 vCPUs and 12 GB memory is recommended for the observability solution.

- **Helm:**
Rancher Desktop has Helm built-in. If not, install [Helm](https://helm.sh/docs/intro/install/)

The following prerequisites are required only for trying out samples.

- **Ballerina:** Install the [Ballerina programming laguage](https://ballerina.io/downloads/).

- **Maven:** [Download](https://maven.apache.org/download.cgi) and [install](https://maven.apache.org/install.html) the Maven build system.

- **Postman:** Download and install the [Postman](https://www.postman.com/downloads/) client for invoking sample APIs. 

#### Deploying the observability solution

Once the prerequisites are setup, the observability solution can be deployed by executing the provided installation script.

1. Clone [this](https://github.com/wso2/observability-resources) repository to a local folder.

2. Navigate to the `<local_folder>/observability-resources/observability/k8s/` folder and execute the installation script using the following command.
```
sh deploy-observability.sh
```
3. Access the observability dashboard
    - Port forward 5601, which is used by the observability dashboard.
    ```
    kubectl port-forward svc/opensearch-dashboards 5601:5601 -n observability
    ```
    - Log in to the OpenSearch dashboard at URL [http://localhost:5601](http://localhost:5601) using the default credentials *(username: admin, password: admin)* 
    - Navigate to *Dashboards* menu.  Click on the *Integration logs dashboard* or *Integration metrics dashboard* to view the required dashboard.

#### Deploying samples

1. Navigate to the `<local_folder>/observability-resources/samples/k8s/` folder and execute the following command to build and deploy all samples:
```
sh deploy_samples.sh
```

2. Port forward 8290 and 9100, which are used by MI and Ballerina deployments.
```
kubectl port-forward svc/bookpark-svc 8290:8290
kubectl port-forward svc/portal-svc 9100:9100
```

### VM

#### Prerequisites

The following prerequisites are needed for deployments on Mac OS. 

>The provided deployment script will check and install missing prerequisites automatically on Debian-based environments.

- **Puppet:** [Puppet](https://www.puppet.com/docs/puppet/8/install_agents#install_agents) is used as the deployment automation system for VM-based deployments.
    - Install the puppetlabs-apt module via
        ```
        puppet module install puppetlabs-apt --version 9.4.0 --modulepath /opt/puppetlabs/puppet/modules/
        ```
    - Install the puppetlabs-docker module via
        ```
        puppet module install puppetlabs-docker --version 10.0.1 --modulepath /opt/puppetlabs/puppet/modules/
        ```

- **JDK 17:** Install [Java Development Kit 17](https://jdk.java.net/archive/)

- **Ballerina:** Install the [Ballerina programming laguage](https://ballerina.io/downloads/) version 2201.10.0.

- **Maven:** [Download](https://maven.apache.org/download.cgi) and [install](https://maven.apache.org/install.html) the Maven build system.

- **wget:** Install wget using the relevant package manager. E.g. for Mac OS: `brew install wget`

- **Postman:** Download and install the [Postman](https://www.postman.com/downloads/) client for invoking sample APIs. 

#### Deploying the observability solution

Once the prerequisites are setup, the observability solution can be deployed by executing the provided installation script.

1. Clone [this](https://github.com/wso2/observability-resources) repository to a local folder.

2. Navigate to the `<local_folder>/observability-resources/observability/vm/` folder and execute the installation script using the following command.

 - Mac OS
    ```
    sh deploy.sh local
    ```
 - Linux (Observability components will be installed as services in Linux. Therefore, `sudo` access is required.)
    ```
    sudo -E sh deploy.sh local
    ```

    Local deployment deploys all components of the observability solution in a single VM. For production deployments, it is recommended to deploy each component in a separate VM by executing deploy.sh followed by the component name as follows:
        - Install OpenSearch: `sh deploy.sh opensearch`
        - Install OpenSearch Dashboards: `sh deploy.sh opensearch-dashboards`
        - Install Fluent Bit: `sh deploy.sh fluentbit` 
        - Install Data Prepper: `sh deploy.sh data-prepper`
    
    Observability components will be deployed as services in Debian-based systems. Therefore, it is required to run the deployment script as the super user in such systems as follows: `sudo -E bash deploy.sh local`

3. Access the observability dashboard
    - Log in to the OpenSearch dashboard at URL [http://localhost:5601](http://localhost:5601) using the default credentials *(username: admin, password: Observer_123)* 
    - Navigate to *Dashboards* menu.  Click on the *Integration logs dashboard* or *Integration metrics dashboard* to view the required dashboard.

#### Deploying samples

1. Download WSO2 Micro Integrator from [here](https://wso2.com/integrator/micro-integrator/) and copy the zip file to the `<local_folder>/observability-resources/files/` folder.

2. Navigate to the `<local_folder>/observability-resources/samples/vm/` folder and execute the following command to build samples and copy binaries to relevant puppet locations:
```
sh deploy.sh prepare
```

3. Run the following command to deploy samples on the local machine:
```
sh deploy.sh local
```

4. Import `<local_folder>/observability-resources/samples/postman/WSO2_Observability.postman_collection.json` to Postman. This contains various requests that cause deployed MI and Ballerina pods to generate logs, tracing data, and metrics data.

## Sample scenarios

A set of sample Ballerina and Micro Integrator deployments are included to try out this solution. Depending on the request payload, these samples generate logs, tracing data, and metrics data, which can be visualized in observability dashboards.

Below are the interactions among sample services when invoking Postman requests.

**Ballerina - Place order**\
Multiple Ballerina services are invoked as shown below:
![order_seq](images/order_seq.png)

**Ballerina - Place order Inventory error**\
Same as *Ballerina - Place order*, but the inventory service causes an error.

**Ballerina - Place order Shipment error**\
Same as *Ballerina - Place order*, but the shipment service causes an error.

**Ballerina - Place order CRM error**\
Same as *Ballerina - Place order*, but the CRM service causes an error.

**MI - Inspection**\
Invokes the Quality inspection service deployed in MI

**MI - Inspection Error**\
Invokes the Quality inspection service deployed in MI, but causes an error

**MI - Inventory**\
Invokes the Inventory service deployed in MI

**MI - Bookstore**\
Multiple MI and Ballerina services are invoked as shown below:
![mi_bookstore](images/MI-bookstore.png)

**Ballerina - Place order Inventory error**\
Same as *MI - Bookstore*, but the shipment service causes an error.

**Bal_MI - Place book order**\
Multiple MI and Ballerina services are invoked as shown below:
![bal_book_order](images/tmart-bookorder.png)

After invoking few Postman requests, observability data related to those invocations can be view as follows.

1. In the OpenSearch dashboard, Navigate to `Dashboards -> Integration logs dashboard` to view log analytics of MI and Ballerina deployments. A logs dashboard, similar to the one shown below, will be displayed with details of MI and Ballerina logs.

![Dashboard](images/dashboard.png)

2. Navigate to `Observability -> Traces` tab to view tracing data of MI and Ballerina service invocations.

![Dashboard](images/trace-dashboard.png)

3. Navigate to `Dashboards -> Integration metrics dashboard` to view metrics data.

![Dashboard](images/metrics-dashboard.png)

# Publishing Ballerina/BI observability data to the observability solution

## VM-based environments

1. Create a `Config.toml` file the below content and set a environment variable named `BAL_CONFIG_FILES` to point to the `Config.toml` file path.
```
[ballerina.observe]
tracingEnabled=true
tracingProvider="jaeger"

[ballerinax.jaeger]
agentHostname="data-prepper.observability.svc.cluster.local"
agentPort=4317
samplerType="const"
samplerParam=1.0
reporterFlushInterval=2000
reporterBufferSize=1000
```

2. Ballerina by default writes logs to the console. In VM-based environments, the observability solution reads logs from log files. Therefore, Ballerina logs have to be directed to a log file. This can be done using one of the below two methods:

    - Run the jar file generated by compiling Ballerina programs by directing console output to a log file.

        ``java -jar <ballerina-program-jar>.jar > logs/app.log 2>&1 &``

    - Direct logs to a log file within the Ballerina program (See [writing Ballerina logs to a file](https://ballerina.io/spec/log/#4-writing-logs-to-a-file) ):

        ``var result = log:setOutputFile("./logs/app.log");``

2. Configure the fluentbit component of the observability solution to the read Ballerina log files. This can be done by adding log file paths of all Ballerina programs to the `<base-dir>/observability-resources/observability/vm/puppet/code/environments/production/modules/fluentbit/manifests/params.pp` file as below:

```
$bal_log_paths = ["/opt/bal_apps/shipments/logs/app.log", "/opt/bal_apps/inventory/logs/app.log", "/opt/bal_apps/crm/logs/app.log", "/opt/bal_apps/portal/logs/app.log"]
```

## Container-based environments

1. Add the `component: "wso2ballerina"` and `app: "<app-name>"` labels to the Ballerina deployment.
2. Create a toml file with the below content and mount it the Ballerina container.
```
[ballerina.observe]
tracingEnabled=true
tracingProvider="jaeger"

[ballerinax.jaeger]
agentHostname="data-prepper.observability.svc.cluster.local"
agentPort=4317
samplerType="const"
samplerParam=1.0
reporterFlushInterval=2000
reporterBufferSize=1000
```
Final Kubernetes deployment file for Ballerina program would look like the below (`files/shipments-config.toml` is the toml file created in step 2):
```
---
apiVersion: "v1"
kind: "Service"
metadata:
  labels:
    app: "shipments"
  name: "shipments-svc"
spec:
  ports:
  - name: "port-1-shipment"
    port: 9101
    protocol: "TCP"
    targetPort: 9101
  selector:
    app: "shipments"
  type: "ClusterIP"
---
apiVersion: "apps/v1"
kind: "Deployment"
metadata:
  labels:
    app: "shipments"
  name: "shipments-deployment"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: "shipments"
  template:
    metadata:
      labels:
        app: "shipments"
        component: "wso2ballerina"
    spec:
      containers:
      - env:
        - name: "BAL_CONFIG_FILES"
          value: "/home/ballerina/conf/Config.toml:"
        image: "tmart/shipments:v1"
        lifecycle:
          preStop:
            exec:
              command:
              - "sleep"
              - "15"
        name: "shipments-deployment"
        ports:
        - containerPort: 9101
          name: "port-1-shipment"
          protocol: "TCP"
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "100Mi"
            cpu: "200m"
        volumeMounts:
        - mountPath: "/home/ballerina/conf/"
          name: "shipments-configmap-volume"
          readOnly: false
      volumes:
      - configMap:
          name: "shipments-configmap"
        name: "shipments-configmap-volume"
---
apiVersion: "autoscaling/v2"
kind: "HorizontalPodAutoscaler"
metadata:
  labels:
    app: "shipments"
  name: "shipments-hpa"
spec:
  maxReplicas: 1
  metrics:
  - resource:
      name: "cpu"
      target:
        averageUtilization: 50
        type: "Utilization"
    type: "Resource"
  minReplicas: 1
  scaleTargetRef:
    apiVersion: "apps/v1"
    kind: "Deployment"
    name: "shipments-deployment"
---
apiVersion: "v1"
kind: "ConfigMap"
metadata:
  name: "shipments-configmap"
data:
  Config.toml: |
{{ .Files.Get "files/shipments-config.toml" | indent 4 }}
```
3. Deploy the Ballerina program in Kubernetes.

# Publishing MI observability data to the observability solution

> **Note:** If no other changes have been made to the log4j.properties file, it is possible to replace the log4j2.properties file with `<base-dir>/observability-resources/samples/vm/puppet/code/environments/production/modules/sample_mi/templates/log4j2.properties.erb` and rename it to log4j2.properties.

1. Add the below analytics logging configuration to the `<mi-home>/conf/deployment.toml` file.
```
[mediation]
flow.statistics.enable=true
flow.statistics.capture_all=true

[analytics]
enabled = true
publisher = "log"
id = "wso2mi_server_1234"
prefix = "SYNAPSE_ANALYTICS_DATA"
api_analytics.enabled = true
proxy_service_analytics.enabled = true
sequence_analytics.enabled = true
endpoint_analytics.enabled = true
inbound_endpoint_analytics.enabled = true

[opentelemetry]
enable = true
logs = true
type = "otlp"
url = "http://data_prepper_host:4317"
```

2. Add the below analytics appender to the `<mi-home>/conf/log4j2.properties` file.

```
# METRICS_LOGFILE is set to be a DailyRollingFileAppender using a PatternLayout.
appender.MI_ANALYTICS_LOGFILE.type = RollingFile
appender.MI_ANALYTICS_LOGFILE.name = MI_ANALYTICS_LOGFILE
appender.MI_ANALYTICS_LOGFILE.fileName = ${sys:carbon.home}/repository/logs/synapse-analytics.log
appender.MI_ANALYTICS_LOGFILE.filePattern = ${sys:carbon.home}/repository/logs/synapse-analytics-%d{MM-dd-yyyy}-%i.log
appender.MI_ANALYTICS_LOGFILE.layout.type = PatternLayout
appender.MI_ANALYTICS_LOGFILE.layout.pattern = [%d{yyyy-MM-dd'T'HH:mm:ss.SSSXXX}] [%X{ip}-%X{host}] [%t] %5p %c{1} %m%n
appender.MI_ANALYTICS_LOGFILE.policies.type = Policies
appender.MI_ANALYTICS_LOGFILE.policies.time.type = TimeBasedTriggeringPolicy
appender.MI_ANALYTICS_LOGFILE.policies.time.interval = 1
appender.MI_ANALYTICS_LOGFILE.policies.time.modulate = true
appender.MI_ANALYTICS_LOGFILE.policies.size.type = SizeBasedTriggeringPolicy
appender.MI_ANALYTICS_LOGFILE.policies.size.size=1000MB
appender.MI_ANALYTICS_LOGFILE.strategy.type = DefaultRolloverStrategy
appender.MI_ANALYTICS_LOGFILE.strategy.max = 10
```
Include this appender in the appenders list in the `<mi-home>/conf/log4j2.properties` file.
```
appenders = CARBON_CONSOLE, CARBON_LOGFILE, METRICS_CONSOLE, MI_ANALYTICS_LOGFILE, AUDIT_LOGFILE, AUDIT_CONSOLE, ATOMIKOS_LOGFILE, ATOMIKOS_CONSOLE, CARBON_TRACE_LOGFILE, CARBON_TRACE_CONSOLE, osgi, SERVICE_LOGFILE, SERVICE_CONSOLE, API_LOGFILE, API_CONSOLE, ERROR_LOGFILE, ERROR_CONSOLE, CORRELATION, CORRELATION_CONSOLE, OPEN_TELEMETRY, HTTP_ACCESS_LOGFILE, HTTP_ACCESS_CONSOLE
```

3. Add the below analytics logger to the `<mi-home>/conf/log4j2.properties` file.

```
logger.ANALYTICS_LOGGER.name = org.wso2.micro.integrator.analytics.messageflow.data.publisher.publish.elasticsearch.ElasticStatisticsPublisher
logger.ANALYTICS_LOGGER.level = DEBUG
logger.ANALYTICS_LOGGER.additivity = false
logger.ANALYTICS_LOGGER.appenderRef.MI_ANALYTICS_LOGFILE.ref = MI_ANALYTICS_LOGFILE
```
Include this appender in the appenders list in the `<mi-home>/conf/log4j2.properties` file.
```
loggers = AUDIT_LOG, ANALYTICS_LOGGER, SERVICE_LOGGER, API_LOGGER, PassThroughAccess,...
```

3. Change the layout pattern of the `CARBON_LOGFILE` appender as below:
```
appender.CARBON_LOGFILE.layout.pattern = [%d{yyyy-MM-dd'T'HH:mm:ss.SSSXXX}] %5p {%c{1}} %X{Artifact-Container} - %m %ex %n
```

loggers = AUDIT_LOG, ANALYTICS_LOGGER, SERVICE_LOGGER, API_LOGGER, PassThroughAccess,

4. Add the following configuration to the fluentbit config file (<base-dir>/observability-resources/observability/vm/puppet/code/environments/production/modules/fluentbit/templates/fluent-bit.conf.erb) to point to the MI logs path.

```
$mi_logs_path = "/opt/mi/wso2mi-4.4.0/repository/logs"
```
