# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::package::apt' do
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
          }
        PUPPET
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_apt__setting('conf-proxy')
          .with(
            'ensure'   => 'present',
            'priority' => '01',
          )
      }

      it {
        is_expected.to contain_apt__setting('conf-proxy')
          .with_content(
            "// This file is managed by Puppet. DO NOT EDIT.\n" \
            "Acquire::http::proxy \"http://proxy.example.com:3128\";\n",
          )
      }
    end
  end
end
