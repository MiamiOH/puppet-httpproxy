# package/apt.pp (private class)
# Uses the puppetlabs-apt module to manage apt package manager proxies
# https://forge.puppetlabs.com/puppetlabs/apt
class httpproxy::package::apt {

  class { '::apt':
    proxy => {
      'ensure' => $httpproxy::packagemanager::ensure,
      'host'   => $httpproxy::_http_proxy,
      'port'   => $httpproxy::http_proxy_port,
    },
  }
  contain '::apt'
}
