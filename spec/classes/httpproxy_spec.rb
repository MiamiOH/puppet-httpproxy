# frozen_string_literal: true

require 'spec_helper'

describe 'httpproxy' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it { is_expected.to compile }

        it {
          is_expected.to contain_class('httpproxy::profiled')
        }

        it {
          is_expected.to contain_class('httpproxy::packagemanager')
        }

        it {
          is_expected.to contain_class('httpproxy::wget')
        }

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_ensure('absent')
        }

        it {
          is_expected.to contain_ini_setting('wget-http_proxy')
            .with_ensure('absent')
        }

        it {
          is_expected.to contain_ini_setting('wget-https_proxy')
            .with_ensure('absent')
        }
      end

      context 'with a proxy configured' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
          }
        end

        it { is_expected.to compile }

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
              %r{export http_proxy=http://proxy\.example\.com:8080},
            )
        }

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_content(
              %r{export https_proxy=http://proxy\.example\.com:8080},
            )
        }

        it {
          is_expected.to contain_ini_setting('wget-http_proxy')
            .with(
              'ensure'  => 'absent',
              'path'    => '/etc/wgetrc',
              'section' => '',
              'setting' => 'http_proxy',
            )
        }

        it {
          is_expected.to contain_ini_setting('wget-https_proxy')
            .with(
              'ensure'  => 'absent',
              'path'    => '/etc/wgetrc',
              'section' => '',
              'setting' => 'https_proxy',
            )
        }
      end

      context 'with no_proxy configured' do
        let(:params) do
          {
            http_proxy:      'proxy.example.com',
            http_proxy_port: 8080,
            no_proxy:        'localhost,127.0.0.1,.example.com',
          }
        end

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_content(
              %r{export no_proxy=localhost,127\.0\.0\.1,\.example\.com},
            )
        }
      end

      context 'with only a proxy host configured' do
        let(:params) do
          {
            http_proxy: 'proxy.example.com',
          }
        end

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_content(
              %r{export http_proxy=http://proxy\.example\.com\n},
            )
        }
      end

      context 'with profiled disabled' do
        let(:params) do
          {
            http_proxy: 'proxy.example.com',
            profiled:   false,
          }
        end

        it {
          is_expected.to contain_file('/etc/profile.d/httpproxy.sh')
            .with_ensure('absent')
        }
      end

      context 'with wget enabled' do
        let(:params) do
          {
            http_proxy: 'proxy.example.com',
            wget:       true,
          }
        end

        it {
          is_expected.to contain_ini_setting('wget-http_proxy')
            .with(
              'ensure'  => 'present',
              'path'    => '/etc/wgetrc',
              'section' => '',
              'setting' => 'http_proxy',
              'value'   => 'http://proxy.example.com',
            )
        }

        it {
          is_expected.to contain_ini_setting('wget-https_proxy')
            .with(
              'ensure'  => 'present',
              'path'    => '/etc/wgetrc',
              'section' => '',
              'setting' => 'https_proxy',
              'value'   => 'http://proxy.example.com',
            )
        }
      end

      context 'with wget disabled' do
        let(:params) do
          {
            http_proxy: 'proxy.example.com',
            wget:       false,
          }
        end

        it {
          is_expected.to contain_ini_setting('wget-http_proxy')
            .with_ensure('absent')
        }

        it {
          is_expected.to contain_ini_setting('wget-https_proxy')
            .with_ensure('absent')
        }
      end

      context 'with package manager disabled' do
        let(:params) do
          {
            http_proxy:     'proxy.example.com',
            packagemanager: false,
          }
        end

        it { is_expected.to compile }

        it {
          if facts[:os]['family'] == 'RedHat'
            is_expected.to contain_ini_setting('yum_proxy')
              .with_ensure('absent')
          end
        }
      end

      if facts[:os]['family'] == 'RedHat'
        context 'on RedHat' do
          let(:params) do
            {
              http_proxy:      'proxy.example.com',
              http_proxy_port: 8080,
            }
          end

          it { is_expected.to compile }

          it {
            is_expected.to contain_ini_setting('yum_proxy')
              .with(
                'ensure'  => 'present',
                'path'    => '/etc/yum.conf',
                'section' => 'main',
                'setting' => 'proxy',
                'value'   => 'http://proxy.example.com:8080',
              )
          }

          it {
            is_expected.to contain_file('/etc/rpm/macros.httpproxy')
              .with(
                'ensure' => 'present',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0644',
              )
          }
        end
      end

      if facts[:os]['family'] == 'Debian'
        context 'on Debian' do
          let(:params) do
            {
              http_proxy: 'proxy.example.com',
            }
          end

          it { is_expected.to compile }

          it {
            is_expected.to contain_apt__setting('conf-proxy')
              .with(
                'ensure'   => 'present',
                'priority' => '01',
              )
          }
        end

        context 'with apt.conf purge enabled' do
          let(:params) do
            {
              http_proxy:      'proxy.example.com',
              purge_apt_conf: true,
            }
          end

          it {
            is_expected.to contain_file('/etc/apt/apt.conf')
              .with_ensure('absent')
          }
        end

        context 'with apt.conf purge disabled' do
          let(:params) do
            {
              http_proxy:      'proxy.example.com',
              purge_apt_conf: false,
            }
          end

          it {
            is_expected.not_to contain_file('/etc/apt/apt.conf')
          }
        end
      end
    end
  end

  context 'with an unsupported OS family' do
    let(:facts) do
      {
        os: {
          family: 'Solaris',
          name:   'Solaris',
        },
      }
    end

    let(:params) do
      {
        http_proxy: 'proxy.example.com',
      }
    end

    it {
      is_expected.to compile.and_raise_error(
        %r{your distro is not supported},
      )
    }
  end
end

