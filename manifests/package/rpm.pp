# package/rpm.pp (private class)
# Manages proxies for the rpm package manager
# /usr/lib/rpm/macros
# Any per-system configuration
# should be added to /etc/rpm/macros
class httpproxy::package::rpm {
  $lines = [
    '# File managed by Puppet',
    '',
    '# The port and machine name of an HTTP proxy host',
    "%_httpport ${httpproxy::http_proxy_port}",
    "%_httpproxy ${httpproxy::http_proxy}",
  ]

  file { '/etc/rpm/macros.httpproxy':
    ensure  => $httpproxy::packagemanager::ensure,
    group   => 'root',
    owner   => 'root',
    mode    => '0644',
    content => join($lines, "\n"),
  }
}
