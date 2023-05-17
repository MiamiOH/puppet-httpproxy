# package/apt.pp (private class)
# Uses the puppetlabs-apt module to manage apt package manager proxies
# https://forge.puppetlabs.com/puppetlabs/apt
class httpproxy::package::apt {
  contain apt

  if !defined(Apt::Setting['conf-proxy']) {
    $content = @("EOL"/L)
    // This file is managed by Puppet. DO NOT EDIT.
    Acquire::http::proxy "http://$httpproxy::http_proxy:$httpproxy::http_proxy_port/";
    | EOL

    apt::setting { 'conf-proxy':
      ensure   => $httpproxy::packagemanager::ensure,
      priority => '01',
      content  => $content,
    }
  }
}
