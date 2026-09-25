# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::packagemanager' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on RedHat family' do
        let(:facts) do
          facts.merge(
            os: facts[:os].merge(
              family: 'RedHat',
            ),
          )
        end

        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => false,
              packagemanager  => true,
              wget            => false,
            }
            contain httpproxy::packagemanager
          PUPPET
        end

        it { is_expected.to compile }

        it 'contains the rpm package handler' do
          is_expected.to contain_class('httpproxy::package::rpm')
        end

        it 'contains the yum package handler' do
          is_expected.to contain_class('httpproxy::package::yum')
        end

        it 'does not contain the apt package handler' do
          is_expected.not_to contain_class('httpproxy::package::apt')
        end
      end

      context 'on Debian family' do
        let(:facts) do
          facts.merge(
            os: facts[:os].merge(
              family: 'Debian',
            ),
          )
        end

        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => false,
              packagemanager  => true,
              wget            => false,
              purge_apt_conf  => false,
            }
            contain httpproxy::packagemanager
          PUPPET
        end

        it { is_expected.to compile }

        it 'contains the apt package handler' do
          is_expected.to contain_class('httpproxy::package::apt')
        end

        it 'does not contain the rpm package handler' do
          is_expected.not_to contain_class('httpproxy::package::rpm')
        end

        it 'does not contain the yum package handler' do
          is_expected.not_to contain_class('httpproxy::package::yum')
        end

        it 'does not contain purge_apt_conf' do
          is_expected.not_to contain_class(
            'httpproxy::package::purge_apt_conf',
          )
        end
      end

      context 'on Debian family with purge_apt_conf enabled' do
        let(:facts) do
          facts.merge(
            os: facts[:os].merge(
              family: 'Debian',
            ),
          )
        end

        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => 'proxy.example.com',
              http_proxy_port => 8080,
              profiled        => false,
              packagemanager  => true,
              wget            => false,
              purge_apt_conf  => true,
            }
            contain httpproxy::packagemanager
          PUPPET
        end

        it { is_expected.to compile }

        it 'contains the apt package handler' do
          is_expected.to contain_class('httpproxy::package::apt')
        end

        it 'contains purge_apt_conf' do
          is_expected.to contain_class(
            'httpproxy::package::purge_apt_conf',
          )
        end
      end

      context 'when package manager configuration is absent' do
        let(:pre_condition) do
          <<~PUPPET
            class { 'httpproxy':
              http_proxy      => undef,
              http_proxy_port => undef,
              profiled        => false,
              packagemanager  => true,
              wget            => false,
            }
            contain httpproxy::packagemanager
          PUPPET
        end

        it { is_expected.to compile }

        if facts[:os]['family'] == 'RedHat'
          it { is_expected.to contain_class('httpproxy::package::rpm') }
          it { is_expected.to contain_class('httpproxy::package::yum') }
        elsif facts[:os]['family'] == 'Debian'
          it { is_expected.to contain_class('httpproxy::package::apt') }
        end
      end
    end
  end
end

