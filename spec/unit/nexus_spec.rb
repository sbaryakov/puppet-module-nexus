require 'spec_helper'

describe 'nexus', :type => :class do

  let :params do
    {
      :base_dir   => '/usr/local',
      :remote_url => 'http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz',
      :tar_name   => 'nexus-latest.tar.gz'
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
        :command  => "/bin/tar --transform='s/nexus-[0-9]*.[0-9]*.[0-9]*-[0-9]*/nexus/' -xzf nexus-latest.tar.gz",
        :cwd     => '/usr/local',
        :creates => '/usr/local/nexus'
      })
    end
    it 'should start it somehow'

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
