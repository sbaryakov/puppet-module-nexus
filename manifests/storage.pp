# this class is private
class nexus::storage {

    filesystem { $nexus::blk_device:
      ensure   => present,
      fs_type  => 'xfs',
      options  => '-f';
    } ->

    mount { "${nexus::base_dir}/sonatype-work":
      ensure   => 'mounted',
      device   => $nexus::blk_device,
      fstype   => 'xfs',
      options  => 'noatime,nodiratime,noexec',
      before   => Exec [ "extract ${nexus::tar_name}"],
      atboot   => true,
    }
}
