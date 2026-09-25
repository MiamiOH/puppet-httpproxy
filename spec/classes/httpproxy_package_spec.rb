# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::packagemanager' do
  context 'on RedHat' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name:   'RedHat',
        },
      }
    end

    let(:pre_condition) do
      <<-PUPPET
        class { 'httpproxy':
          http_proxy => 'proxy.example.com',
          http_proxy_port => 8080,
          packagemanager => true,
        }
      PUPPET
    end

    it { is_expected.to compile }

    it { is_expected.to contain_class('httpproxy::package::rpm') }
    it { is_expected.to contain_class('httpproxy::package::yum') }

    it {
      is_expected.to contain_file('/etc/rpm/macros.httpproxy')
        .with_ensure('present')
    }

    it {
      is_expected.to contain_ini_setting('yum_proxy')
        .with(
          'ensure'  => 'present',
          'path'    => '/etc/yum.conf',
          'section' => 'main',
          'setting' => 'proxy',
          'value'   => 'http://proxy.example.com:8080',
        )
    }
  end

  context 'on Debian' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name:   'Debian',
        },
      }
    end

    let(:pre_condition) do
      <<-PUPPET
        class { 'httpproxy':
          http_proxy => 'proxy.example.com',
          http_proxy_port => 3128,
          packagemanager => true,
        }
      PUPPET
    end

    it { is_expected.to compile }

    it { is_expected.to contain_class('httpproxy::package::apt') }

    it {
      is_expected.to contain_apt__setting('conf-proxy')
        .with(
          'ensure'   => 'present',
          'priority' => '01',
        )
    }
  end

  context 'on Debian with apt.conf purge enabled' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name:   'Debian',
        },
      }
    end

    let(:pre_condition) do
      <<-PUPPET
        class { 'httpproxy':
          http_proxy => 'proxy.example.com',
          packagemanager => true,
          purge_apt_conf => true,
        }
      PUPPET
    end

    it {
      is_expected.to contain_file('/etc/apt/apt.conf')
        .with_ensure('absent')
    }
  end

  context 'on Debian with apt.conf purge disabled' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name:   'Debian',
        },
      }
    end

    let(:pre_condition) do
      <<-PUPPET
        class { 'httpproxy':
          http_proxy => 'proxy.example.com',
          packagemanager => true,
          purge_apt_conf => false,
        }
      PUPPET
    end

    it {
      is_expected.not_to contain_file('/etc/apt/apt.conf')
    }
  end

  context 'with package management disabled' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name:   'RedHat',
        },
      }
    end

    let(:pre_condition) do
      <<-PUPPET
        class { 'httpproxy':
          http_proxy => 'proxy.example.com',
          packagemanager => false,
        }
      PUPPET
    end

    it {
      is_expected.to contain_file('/etc/rpm/macros.httpproxy')
        .with_ensure('absent')
    }

    it {
      is_expected.to contain_ini_setting('yum_proxy')
        .with_ensure('absent')
    }
  end
end
