class common::java {
  # Copy JDK to Java distribution path
  if $pack_location == "local" {
    file { "jdk-distribution":
      path   => "${java_home}.tar.gz",
      source => "puppet:///modules/common/jdk/${jdk_name}.tar.gz",
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

  # Unzip distribution
  exec { "unpack-jdk":
    command => "tar -zxvf ${java_home}.tar.gz",
    path    => "/bin/",
    cwd     => "${java_dir}",
    onlyif  => "/usr/bin/test ! -d ${java_home}",
  }

  # Create symlink to Java binary
  file { "${java_symlink}":
    ensure  => "link",
    target  => "${java_home}",
    require => Exec["unpack-jdk"]
  }
}
