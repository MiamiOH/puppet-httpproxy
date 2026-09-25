# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::wget' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with a proxy' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => false,
              packagemanager  => false,
              wget            => true,
            }
            contain httpproxy::wget
          PUPPET
        end

        it { is_expected.to compile }

        it 'configures the wget http proxy' do
          is_expected.to contain_ini_setting('wget-http_proxy').with(
            ensure:  'present',
            path:    '/etc/wgetrc',
            section: '',
            setting: 'http_proxy',
            value:   'http://proxy.example.com:8080',
          )
        end

        it 'configures the wget https proxy' do
          is_expected.to contain_ini_setting('wget-https_proxy').with(
            ensure:  'present',
            path:    '/etc/wgetrc',
            section: '',
            setting: 'https_proxy',
            value:   'http://proxy.example.com:8080',
          )
        end
      end

      context 'with a proxy without a port' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => undef,
              profiled        => false,
              packagemanager  => false,
              wget            => true,
            }
            contain httpproxy::wget
          PUPPET
        end

        it { is_expected.to compile }

        it 'configures http_proxy without a port' do
          is_expected.to contain_ini_setting('wget-http_proxy').with(
            ensure:  'present',
            path:    '/etc/wgetrc',
            section: '',
            setting: 'http_proxy',
            value:   'http://proxy.example.com',
          )
        end

        it 'configures https_proxy without a port' do
          is_expected.to contain_ini_setting('wget-https_proxy').with(
            ensure:  'present',
            path:    '/etc/wgetrc',
            section: '',
            setting: 'https_proxy',
            value:   'http://proxy.example.com',
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
              packagemanager  => false,
              wget            => true,
            }
            contain httpproxy::wget
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the wget http proxy setting' do
          is_expected.to contain_ini_setting('wget-http_proxy').with(
            ensure: 'absent',
          )
        end

        it 'removes the wget https proxy setting' do
          is_expected.to contain_ini_setting('wget-https_proxy').with(
            ensure: 'absent',
          )
        end
      end

      context 'when wget is set to absent' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => false,
              packagemanager  => false,
              wget            => 'absent',
            }
            contain httpproxy::wget
          PUPPET
        end

        it { is_expected.to compile }

        it 'removes the wget http proxy setting' do
          is_expected.to contain_ini_setting('wget-http_proxy').with(
            ensure: 'absent',
          )
        end

        it 'removes the wget https proxy setting' do
          is_expected.to contain_ini_setting('wget-https_proxy').with(
            ensure: 'absent',
          )
        end
      end
    end
  end
end

