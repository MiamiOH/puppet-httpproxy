# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy::wget' do
  let(:facts) do
    on_supported_os.first.last
  end

  context 'when enabled' do
    let(:pre_condition) do
      <<~PUPPET
        class { 'httpproxy':
          http_proxy      => 'proxy.example.com',
          http_proxy_port => 3128,
          wget            => true,
        }
      PUPPET
    end

    it { is_expected.to compile }

    it {
      is_expected.to contain_ini_setting('wget-http_proxy')
        .with(
          'ensure'  => 'present',
          'path'    => '/etc/wgetrc',
          'section' => '',
          'setting' => 'http_proxy',
          'value'   => 'http://proxy.example.com:3128',
        )
    }

    it {
      is_expected.to contain_ini_setting('wget-https_proxy')
        .with(
          'ensure'  => 'present',
          'path'    => '/etc/wgetrc',
          'section' => '',
          'setting' => 'https_proxy',
          'value'   => 'http://proxy.example.com:3128',
        )
    }
  end

  context 'when disabled' do
    let(:pre_condition) do
      <<~PUPPET
        class { 'httpproxy':
          http_proxy      => 'proxy.example.com',
          http_proxy_port => 3128,
          wget            => false,
        }
      PUPPET
    end

    it { is_expected.to compile }

    it {
      is_expected.to contain_ini_setting('wget-http_proxy')
        .with_ensure('absent')
    }

    it {
      is_expected.to contain_ini_setting('wget-https_proxy')
        .with_ensure('absent')
    }
  end
end
