# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::profiled' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with profiled enabled' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => true,
            }
          PUPPET
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/profile.d')
            .with(
              'ensure' => 'directory',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755',
            )
        }

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with(
              'ensure' => 'present',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644',
            )
        }

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_content(
              "# Set http proxy for shell\n" \
              "export http_proxy=http://proxy.example.com:8080\n" \
              "export https_proxy=http://proxy.example.com:8080\n",
            )
        }
      end

      context 'with no_proxy configured' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              no_proxy        => 'localhost,127.0.0.1,.example.com',
              profiled        => true,
            }
          PUPPET
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_content(
              "# Set http proxy for shell\n" \
              "export http_proxy=http://proxy.example.com:8080\n" \
              "export https_proxy=http://proxy.example.com:8080\n" \
              "export no_proxy=localhost,127.0.0.1,.example.com\n",
            )
        }
      end

      context 'when profiled is disabled' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy => 'proxy.example.com',
              profiled   => false,
            }
          PUPPET
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_ensure('absent')
        }
      end

      context 'when proxy is absent' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy => undef,
              profiled   => true,
            }
          PUPPET
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_ensure('absent')
        }
      end
    end
  end
end
