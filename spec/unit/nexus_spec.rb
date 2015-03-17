require 'spec_helper'

describe 'nexus', :type => :class do

  let :params do
    {
      :base_dir     => '/usr/local',
      :run_as_user  => 'nexus',
      :remote_url   => 'http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz',
      :tar_name     => 'nexus-latest.tar.gz',
      :install_java => true,
    }
  end

  context 'on redhat systems' do

    let :facts do
      {
        :osfamily           => 'redhat',
        :operatingsystem    => 'redhat'
      }
    end

    it 'should include java' do
      should contain_class('java')
    end

    it 'should download and unpack the latest nexus version' do
      should contain_staging__file('nexus-latest.tar.gz').with_source('http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz')
      should contain_exec('extract nexus-latest.tar.gz').with({
        :command  => "/bin/tar --transform='s/nexus-[0-9]*.[0-9]*.[0-9]*-[0-9]*/nexus/' -xzf /opt/staging/nexus/nexus-latest.tar.gz",
        :cwd     => '/usr/local',
        :creates => '/usr/local/nexus'
      })
    end

    it 'should start it somehow' do
      should contain_file('/etc/init.d/nexus')
        .with_content(/^NEXUS_HOME=\"\/usr\/local\/nexus\"$/)
        .with_content(/^RUN_AS_USER=\"nexus\"/)

      should contain_service('nexus').with_ensure('running')
    end

    it 'should create a nexus user' do
      should contain_user('nexus')
    end

    it 'should contain file security.xml with default admin password' do
      should contain_file('/usr/local/sonatype-work/nexus/conf/security.xml').with_content(
        %r[\$shiro1\$SHA-512\$1024\$G\+rxqm4Qw5/J54twR6BrSQ==\$2ZUS4aBHbGGZkNzLugcQqhea7uPOXhoY4kugop4r4oSAYlJTyJ9RyZYLuFBmNzDr16Ii1Q\+O6Mn1QpyBA1QphA==]
      )
    end

    it 'should contain file security-configuration.xml with anonymousAccessEnabled false' do
      should contain_file('/usr/local/sonatype-work/nexus/conf/security-configuration.xml').with_content(
        %r[<anonymousAccessEnabled>false</anonymousAccessEnabled>]
      )
    end

    context 'when install_java param is false' do
      let(:params) {{ :install_java => false }}

      it 'should not include java' do
        should_not contain_class('java')
      end
    end
  end

  context 'on unsupported osfamilies' do
    let :facts do
      {
        :osfamily => 'fuuuu'
      }
    end

    it 'should fail with an error' do
      compile.and_raise_error(/unsupported/)
    end
  end

  context 'with mounted storage' do
    let :params do
      {
        :base_dir      => '/usr/local',
        :run_as_user   => 'nexus',
        :remote_url    => 'http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz',
        :tar_name      => 'nexus-latest.tar.gz',
        :install_java  => false,
        :blk_device    => '/dev/sdb',
        :mount_storage => true
      }
    end
    let :facts do
      {
        :osfamily           => 'redhat',
        :operatingsystem    => 'redhat'
      }
    end

    it 'should contain storage class' do
      should contain_class('nexus::storage')
    end

    it 'should contain xfs filesystem on the correct block device' do
      should contain_filesystem('/dev/sdb').with({:fs_type => 'xfs'})
    end

    it 'should contain mount' do
      should contain_mount('/usr/local/sonatype-work').with({:device => '/dev/sdb'})
    end

  end

end
