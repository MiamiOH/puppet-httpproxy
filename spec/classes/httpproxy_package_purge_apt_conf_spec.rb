# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::package::purge_apt_conf' do
  on_supported_os.each do |os, facts|
    next unless facts[:os]['family'] == 'Debian'

    context "on #{os}" do
      let(:facts) { facts }

      let(:pre_condition) do
        <<~PUPPET
          class { 'httpproxy':
            http_proxy      => 'proxy.example.com',
            http_proxy_port => 3128,
            packagemanager  => true,
            purge_apt_conf  => true,
          }
        PUPPET
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/apt/apt.conf')
          .with(
            'ensure' => 'absent',
          )
      }
    end
  end
end

