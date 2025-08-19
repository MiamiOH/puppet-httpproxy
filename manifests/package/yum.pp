# package/yum.pp (private class)
# Manages proxies for the yum package manager
# Uses the puppetlabs/inifile resource
# https://forge.puppetlabs.com/puppetlabs/inifile
class httpproxy::package::yum {
  ini_setting { 'yum_proxy':
    ensure  => $httpproxy::packagemanager::ensure,
    path    => '/etc/yum.conf',
    section => 'main',
    setting => 'proxy',
    value   => $httpproxy::proxy_uri,
  }
}
