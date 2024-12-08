class o11y_common::java inherits o11y_common::params {

# Check if Java is installed by running `java --version`
$java_installed = inline_template('<%=`which java 2>&1`.empty? ? false : true %>')

if $java_installed == "false" {
  notify { 'Java is not installed. Installing Java...': }

  if $pack_location == "local" {
    file { "jdk-distribution":
      path   => "${java_home}.tar.gz",
      source => "puppet:///modules/${module_name}/${jdk_name}.tar.gz",
      notify => Exec["unpack-jdk"],
    }
  }
  elsif $pack_location == "remote" {
    exec { "retrieve-jdk":
      command => "wget -q ${remote_jdk} -O ${java_home}.tar.gz",
      path    => "/usr/bin/",
      onlyif  => "/usr/bin/test ! -f ${java_home}.tar.gz",
      notify  => Exec["unpack-jdk"],
    }
  }

  # Unpack distribution
  exec { "unpack-jdk":
    command => "tar -zxvf ${java_home}.tar.gz",
    path    => $path,
    cwd     => "${java_dir}",
  }

  # Create symlink to Java binary
  file { "${java_symlink}":
    ensure  => "link",
    target  => "${java_home}/bin/java",
    require => Exec["unpack-jdk"]
  }

  file { "remove_java_archive":
      path   => "${java_home}.tar.gz",
      ensure => absent,
      require => Exec["unpack-jdk"]
  }
} else {
  notify { 'Java is already installed': }
}
}
