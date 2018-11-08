# package/apt.pp (private class)
# Writes a conf.d file to make Apt use the proxy
class httpproxy::package::apt {
  file { 'apt_via_proxy':
    path    => '/etc/apt/apt.conf.d/05proxy',
    ensure  => $httpproxy::packagemanager::ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Acquire::http::Proxy \"http://${httpproxy::http_proxy}:${httpproxy::http_proxy_port}\";"
  }
}
