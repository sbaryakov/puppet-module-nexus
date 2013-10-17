# Class: nexus
#
#
class nexus(
  $base_dir    = '/usr/local',
  $run_as_user = 'nexus',
  $remote_url  = 'http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz',
  $tar_name    = 'nexus-latest.tar.gz'
) {

  include java

  $nexus_home = "${base_dir}/nexus"

  if $::osfamily != 'RedHat' {
    fail("unsupported osfamily \"${::osfamily}\"")
  }

  class { 'staging':
    path => '/opt/staging',
  }

  staging::file { $tar_name:
    source => $remote_url,
  } ->

  exec { "extract ${tar_name}":
    command   => "/bin/tar --transform='s/nexus-[0-9]*.[0-9]*.[0-9]*-[0-9]*/nexus/' -xzf /opt/staging/nexus/${tar_name}",
    cwd       => $base_dir,
    creates   => "${base_dir}/nexus",
    logoutput => on_failure,
  } ->

  file { '/etc/init.d/nexus':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nexus/nexus.init.erb'),
  } ->

  service { 'nexus':
    ensure => 'running',
  }

  if !defined(User[$run_as_user]) {
    user { $run_as_user :
      ensure  => present,
      home    => $nexus_home,
      require => Service['nexus'],
    }
  }

}