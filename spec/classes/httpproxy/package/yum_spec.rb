# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::package::yum' do
  on_supported_os.select { |_os, facts| facts[:os]['family'] == 'RedHat' }.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with a proxy' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => false,
              packagemanager  => true,
              wget            => false,
            }
            contain httpproxy::package::yum
          PUPPET
        end

        it { is_expected.to compile }

        it 'configures the yum proxy' do
          is_expected.to contain_ini_setting('yum_proxy').with(
            ensure:  'present',
            path:    '/etc/yum.conf',
            section: 'main',
            setting: 'proxy',
            value:   'http://proxy.example.com:8080',
          )
        end
      end

      context 'without a proxy' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => undef,
              http_proxy_port => undef,
              profiled        => false,
              packagemanager  => true,
              wget            => false,
            }
            contain httpproxy::package::yum
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the yum proxy' do
          is_expected.to contain_ini_setting('yum_proxy').with(
            ensure: 'absent',
          )
        end
      end

      context 'when packagemanager is set to absent' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => false,
              packagemanager  => 'absent',
              wget            => false,
            }
            contain httpproxy::package::yum
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the yum proxy' do
          is_expected.to contain_ini_setting('yum_proxy').with(
            ensure: 'absent',
          )
        end
      end
    end
  end
end

