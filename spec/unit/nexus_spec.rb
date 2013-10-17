require 'spec_helper'

describe 'nexus', :type => :class do

  let :params do
    {
      :base_dir    => '/usr/local',
      :run_as_user => 'nexus',
      :remote_url  => 'http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz',
      :tar_name    => 'nexus-latest.tar.gz'
    }
  end

  context 'on redhat systems' do

    let :facts do
      {
        :osfamily => 'redhat'
      }
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

  end

  context 'on unsupported osfamilies' do
    let :facts do
      {
        :osfamily => 'fuuuu'
      }
    end

    it 'should fail with an error' do
      expect { subject }.to raise_error(Puppet::Error,/unsupported osfamily \"fuuuu\"/)
    end
  end


end
