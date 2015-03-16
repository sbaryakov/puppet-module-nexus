# Class: nexus
#
#
class nexus(
  $base_dir            = '/usr/local',
  $run_as_user         = 'nexus',
  $remote_url          = 'http://download.sonatype.com/nexus/oss/nexus-latest-bundle.tar.gz',
  $tar_name            = 'nexus-latest.tar.gz',
  $java_initmemory     = 128,
  $java_maxmemory      = 256,
  $install_java        = true,
  $admin_password_sha1 = undef,
  $anonymous_status    = undef
) {

  if $install_java == true {
    include java
  }

  $nexus_home = "${base_dir}/nexus"

  if $::osfamily != 'RedHat' {
    fail("unsupported osfamily \"${::osfamily}\"")
  }

  class { 'staging':
    path => '/opt/staging',
  }

  if !defined(User[$run_as_user]) {
    user { $run_as_user :
      ensure  => present,
      home    => $nexus_home,
    }

    User[$run_as_user] -> File[$nexus_home, "${base_dir}/sonatype-work"] -> Service['nexus']
  }

  staging::file { $tar_name:
    source => $remote_url,
  } ->

  exec { "extract ${tar_name}":
    command   => "/bin/tar --transform='s/nexus-[0-9]*.[0-9]*.[0-9]*-[0-9]*/nexus/' -xzf /opt/staging/nexus/${tar_name}",
    cwd       => $base_dir,
    creates   => $nexus_home,
    logoutput => on_failure,
  } ->

  file { $nexus_home:
    ensure  => directory,
    recurse => true,
    owner   => $run_as_user,
    group   => $run_as_user,
    mode    => '0775',
  } ->

  file { "${base_dir}/sonatype-work":
    ensure  => directory,
    recurse => true,
    owner   => $run_as_user,
    group   => $run_as_user,
    mode    => '0644',
  } ->

  file { '/etc/init.d/nexus':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nexus/nexus.init.erb'),
  } ->

  ini_setting {
    'java_initmemory':
      ensure  => present,
      path    => "${base_dir}/nexus/bin/jsw/conf/wrapper.conf",
      section => '',
      setting => 'wrapper.java.initmemory',
      value   => $java_initmemory;

    'java_maxmemory':
      ensure  => present,
      path    => "${base_dir}/nexus/bin/jsw/conf/wrapper.conf",
      section => '',
      setting => 'wrapper.java.maxmemory',
      value   => $java_maxmemory;
  } ->

  service { 'nexus':
    ensure => 'running',
    enable => true
  }

  file { "${base_dir}/sonatype-work/nexus/conf/security.xml":
    content => template('nexus/security.xml.erb'),
    mode    => '644',
    require => Exec [ "extract ${tar_name}"],
  }
}
