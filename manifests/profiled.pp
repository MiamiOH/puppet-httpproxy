# Profiled.pp (private class)
# Manages proxies in profile.d

class httpproxy::profiled {
  $ensure = $httpproxy::profiled ? {
    true    => $httpproxy::ensure,
    default => $httpproxy::profiled,
  }

  if $httpproxy::no_proxy {
    $lines = [
      '# Set http proxy for shell',
      "export http_proxy=${httpproxy::proxy_uri}",
      "export https_proxy=${httpproxy::proxy_uri}",
      "export no_proxy=${httpproxy::no_proxy}",
    ]
  }
  else {
    $lines = [
      '# Set http proxy for shell',
      "export http_proxy=${httpproxy::proxy_uri}",
      "export https_proxy=${httpproxy::proxy_uri}",
    ]
  }

  file { '/etc/profile.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/profile.d/httpproxy.sh':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${join($lines, "\n")}\n",
    require => File['/etc/profile.d'],
  }
}
