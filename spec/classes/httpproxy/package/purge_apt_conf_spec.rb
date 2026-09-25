# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::package::purge_apt_conf' do
  on_supported_os.select { |_os, facts| facts[:os]['family'] == 'Debian' }.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

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
          contain httpproxy::package::purge_apt_conf
        PUPPET
      end

      it { is_expected.to compile }

      it 'removes /etc/apt/apt.conf' do
        is_expected.to contain_file('/etc/apt/apt.conf').with(
          ensure: 'absent',
        )
      end
    end
  end
end

