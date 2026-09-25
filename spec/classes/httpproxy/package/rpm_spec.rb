# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::package::rpm' do
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
            contain httpproxy::package::rpm
          PUPPET
        end

        it { is_expected.to compile }

        it 'creates the rpm proxy configuration' do
          is_expected.to contain_file('/etc/rpm/macros.httpproxy').with(
            ensure: 'present',
            group:  'root',
            owner:  'root',
            mode:   '0644',
            content: %r{%_httpport 8080},
          )
        end

        it 'configures the proxy host' do
          is_expected.to contain_file('/etc/rpm/macros.httpproxy').with(
            content: %r{%_httpproxy proxy\.example\.com},
          )
        end

        it 'contains the Puppet management header' do
          is_expected.to contain_file('/etc/rpm/macros.httpproxy').with(
            content: %r{# File managed by Puppet},
          )
        end
      end

      context 'when proxy configuration is absent' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => undef,
              http_proxy_port => undef,
              profiled        => false,
              packagemanager  => true,
              wget            => false,
            }
            contain httpproxy::package::rpm
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the rpm configuration' do
          is_expected.to contain_file('/etc/rpm/macros.httpproxy').with(
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
            contain httpproxy::package::rpm
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the rpm configuration' do
          is_expected.to contain_file('/etc/rpm/macros.httpproxy').with(
            ensure: 'absent',
          )
        end
      end
    end
  end
end

