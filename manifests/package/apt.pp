# package/apt.pp (private class)
# Uses the puppetlabs-apt module to manage apt package manager proxies
# https://forge.puppetlabs.com/puppetlabs/apt
class httpproxy::package::apt {
  contain apt

# lint:ignore:variables_not_enclosed lint:ignore:strict_indent
  if !defined(Apt::Setting['conf-proxy']) {
    $content = @("EOL"/L)
    // This file is managed by Puppet. DO NOT EDIT.
    Acquire::http::proxy "http://$httpproxy::http_proxy:$httpproxy::http_proxy_port/";
    | EOL
# lint:endignore

    apt::setting { 'conf-proxy':
      ensure   => $httpproxy::packagemanager::ensure,
      priority => '01',
      content  => $content,
    }
  }
}
