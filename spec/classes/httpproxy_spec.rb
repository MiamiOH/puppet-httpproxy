# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with proxy configuration' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            no_proxy:        'localhost,127.0.0.1',
            profiled:        true,
            packagemanager:  true,
            wget:            true,
          }
        end

        it { is_expected.to compile }

        it 'contains httpproxy::profiled' do
          is_expected.to contain_class('httpproxy::profiled')
        end

        it 'contains httpproxy::packagemanager' do
          is_expected.to contain_class('httpproxy::packagemanager')
        end

        it 'contains httpproxy::wget' do
          is_expected.to contain_class('httpproxy::wget')
        end
      end

      context 'with all optional features disabled' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            profiled:        false,
            packagemanager:  false,
            wget:            false,
          }
        end

        it { is_expected.to compile }

        it 'does not contain httpproxy::profiled' do
          is_expected.not_to contain_class('httpproxy::profiled')
        end

        it 'does not contain httpproxy::packagemanager' do
          is_expected.not_to contain_class('httpproxy::packagemanager')
        end

        it 'does not contain httpproxy::wget' do
          is_expected.not_to contain_class('httpproxy::wget')
        end
      end

      context 'when only profiled is enabled' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            profiled:        true,
            packagemanager:  false,
            wget:            false,
          }
        end

        it { is_expected.to compile }

        it 'contains httpproxy::profiled' do
          is_expected.to contain_class('httpproxy::profiled')
        end

        it 'does not contain httpproxy::packagemanager' do
          is_expected.not_to contain_class('httpproxy::packagemanager')
        end

        it 'does not contain httpproxy::wget' do
          is_expected.not_to contain_class('httpproxy::wget')
        end
      end

      context 'when only packagemanager is enabled' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            profiled:        false,
            packagemanager:  true,
            wget:            false,
          }
        end

        it { is_expected.to compile }

        it 'does not contain httpproxy::profiled' do
          is_expected.not_to contain_class('httpproxy::profiled')
        end

        it 'contains httpproxy::packagemanager' do
          is_expected.to contain_class('httpproxy::packagemanager')
        end

        it 'does not contain httpproxy::wget' do
          is_expected.not_to contain_class('httpproxy::wget')
        end
      end

      context 'when only wget is enabled' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            profiled:        false,
            packagemanager:  false,
            wget:            true,
          }
        end

        it { is_expected.to compile }

        it 'does not contain httpproxy::profiled' do
          is_expected.not_to contain_class('httpproxy::profiled')
        end

        it 'does not contain httpproxy::packagemanager' do
          is_expected.not_to contain_class('httpproxy::packagemanager')
        end

        it 'contains httpproxy::wget' do
          is_expected.to contain_class('httpproxy::wget')
        end
      end

      context 'when http_proxy is configured without a port' do
        let(:params) do
          {
            http_proxy:     'proxy.example.com',
            profiled:       false,
            packagemanager: false,
            wget:           true,
          }
        end

        it { is_expected.to compile }

        it 'does not contain httpproxy::profiled' do
          is_expected.not_to contain_class('httpproxy::profiled')
        end

        it 'does not contain httpproxy::packagemanager' do
          is_expected.not_to contain_class('httpproxy::packagemanager')
        end

        it 'contains httpproxy::wget' do
          is_expected.to contain_class('httpproxy::wget')
        end
      end

      context 'when proxy configuration is absent' do
        let(:params) do
          {
            profiled:       true,
            packagemanager: true,
            wget:           true,
          }
        end

        it { is_expected.to compile }

        it 'contains httpproxy::profiled' do
          is_expected.to contain_class('httpproxy::profiled')
        end

        it 'contains httpproxy::packagemanager' do
          is_expected.to contain_class('httpproxy::packagemanager')
        end

        it 'contains httpproxy::wget' do
          is_expected.to contain_class('httpproxy::wget')
        end
      end

      context 'when purge_apt_conf is disabled' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            profiled:        false,
            packagemanager:  true,
            wget:            false,
            purge_apt_conf:  false,
          }
        end

        it { is_expected.to compile }

        it 'contains httpproxy::packagemanager' do
          is_expected.to contain_class('httpproxy::packagemanager')
        end

        if facts[:os]['family'] == 'Debian'
          it 'does not contain purge_apt_conf' do
            is_expected.not_to contain_class(
              'httpproxy::package::purge_apt_conf',
            )
          end
        end
      end

      context 'when purge_apt_conf is enabled' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            profiled:        false,
            packagemanager:  true,
            wget:            false,
            purge_apt_conf:  true,
          }
        end

        if facts[:os]['family'] == 'Debian'
          it { is_expected.to compile }

          it 'contains httpproxy::packagemanager' do
            is_expected.to contain_class('httpproxy::packagemanager')
          end

          it 'contains purge_apt_conf' do
            is_expected.to contain_class(
              'httpproxy::package::purge_apt_conf',
            )
          end
        else
          it { is_expected.to compile }

          it 'contains httpproxy::packagemanager' do
            is_expected.to contain_class('httpproxy::packagemanager')
          end
        end
      end
    end
  end
end

