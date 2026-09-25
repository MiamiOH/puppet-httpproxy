# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::profiled' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with a proxy and no_proxy' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              no_proxy        => 'localhost,127.0.0.1',
              profiled        => true,
              packagemanager  => false,
              wget            => false,
            }
            contain httpproxy::profiled
          PUPPET
        end

        it { is_expected.to compile }

        it 'creates /etc/profile.d' do
          is_expected.to contain_file('/etc/profile.d').with(
            ensure: 'directory',
            owner:  'root',
            group:  'root',
            mode:   '0755',
          )
        end

        it 'creates the proxy profile' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            ensure: 'present',
            owner:  'root',
            group:  'root',
            mode:   '0644',
          )
        end

        it 'configures http_proxy' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            content: %r{export http_proxy=http://proxy\.example\.com:8080},
          )
        end

        it 'configures https_proxy' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            content: %r{export https_proxy=http://proxy\.example\.com:8080},
          )
        end

        it 'configures no_proxy' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            content: %r{export no_proxy=localhost,127\.0\.0\.1},
          )
        end

        it 'requires the profile.d directory' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').that_requires(
            'File[/etc/profile.d]',
          )
        end
      end

      context 'without no_proxy' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              no_proxy        => undef,
              profiled        => true,
              packagemanager  => false,
              wget             => false,
            }
            contain httpproxy::profiled
          PUPPET
        end

        it { is_expected.to compile }

        it 'configures http_proxy' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            content: %r{export http_proxy=http://proxy\.example\.com:8080},
          )
        end

        it 'configures https_proxy' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            content: %r{export https_proxy=http://proxy\.example\.com:8080},
          )
        end

        it 'does not configure no_proxy' do
          is_expected.not_to contain_file('/etc/profile.d/httpproxy.sh').with(
            content: %r{export no_proxy=},
          )
        end
      end

      context 'when proxy configuration is absent' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => undef,
              http_proxy_port => undef,
              profiled        => true,
              packagemanager  => false,
              wget             => false,
            }
            contain httpproxy::profiled
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the profile' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            ensure: 'absent',
          )
        end
      end

      context 'when profiled is set to absent' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => 'absent',
              packagemanager  => false,
              wget             => false,
            }
            contain httpproxy::profiled
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the profile' do
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh').with(
            ensure: 'absent',
          )
        end
      end
    end
  end
end

