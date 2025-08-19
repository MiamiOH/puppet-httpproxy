# wget.pp (private class)
# Manages proxies for the popular wget file downloader
# Uses the puppetlabs/inifile resource
# https://forge.puppetlabs.com/puppetlabs/inifile
class httpproxy::wget {
  $ensure = $httpproxy::wget ? {
    true    => $httpproxy::ensure,
    default => $httpproxy::wget,
  }

  # Writes ini settings defined in init.pp in the wget configuration file.
  ini_setting { 'wget-http_proxy':
    ensure  => $ensure,
    path    => '/etc/wgetrc',
    section => '',
    setting => 'http_proxy',
    value   => $httpproxy::proxy_uri,
  }
  # Writes "https" setting. This module does not support https so it uses whatever is specified for http.
  ini_setting { 'wget-https_proxy':
    ensure  => $ensure,
    path    => '/etc/wgetrc',
    section => '',
    setting => 'https_proxy',
    value   => $httpproxy::proxy_uri,
  }
}
