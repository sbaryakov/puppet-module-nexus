# Class: nexus
#
#
class nexus(
  $base_dir   = '/usr/local',
  $remote_url = 'http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz',
  $tar_name   = 'nexus-latest.tar.gz'
) {

  if $::osfamily != 'RedHat' {
    fail("unsupported osfamily \"${::osfamily}\"")
  }

  class { 'staging':
    path => $base_dir,
  }

  staging::file { $tar_name:
    source => $remote_url,
  }

  exec { "extract ${tar_name}":
    command   => "/bin/tar --transform='s/nexus-[0-9]*\.[0-9]*\.[0-9]*-[0-9]*/nexus/' -xzf ${tar_name}",
    cwd       => $base_dir,
    creates   => "${base_dir}/nexus",
    logoutput => on_failure,
  }

}