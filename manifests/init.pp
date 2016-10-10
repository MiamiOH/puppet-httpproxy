# init.pp
# Manages http proxies for various software
# Defines the httpproxy class. Sets the $http_proxy and $http_proxy_port variable to null.
class httpproxy (
  $http_proxy      = undef,
  $http_proxy_port = undef,
  $no_proxy        = undef,
  $profiled        = true,
  $packagemanager  = true,
  $wget            = false,
  $purge_apt_conf  = false,
){

  # Validates that $http_proxy is a valid, usable domain name or IP address
  if $http_proxy and size($http_proxy) > 3 {   # '.' is an RFC-valid domain name, but not usable in this context
    if is_ipv4_address($http_proxy) or is_domain_name($http_proxy) {
      $proxy_is_valid = true
    } elsif is_ipv6_address($http_proxy) { # IPv6 needs to be enclosed in []
      $http_proxy = enclose_ipv6($http_proxy)
      $proxy_is_valid = true
    } else {
      # Invalid proxy specified - could also 'undef' the value an continue??
      $proxy_is_valid = 'No, the proxy is not valid'
    }
    validate_bool($proxy_is_valid)
  }
  # Validate that $http_proxy_port is a valid port number
  if $http_proxy_port {
    validate_integer($http_proxy_port, 65535, 0)
  }
  validate_bool($purge_apt_conf)

  # Checks if $http_proxy contains a string. If $http_proxy is null $ensure is set to absent.
  # If $http_proxy contains a string then $ensure is set to present.
  $ensure = $http_proxy ? {
    undef   => 'absent',
    default => 'present',
  }

  # Checks if $http_proxy_port contains a string. If $http_proxy_port is null, $proxy_port_string
  # is set to null. Otherwise, a colon is added in front of $http_proxy_port and stored in
  # $proxy_port_string
  $proxy_port_string = $http_proxy_port ? {
    undef   => undef,
    default => ":${http_proxy_port}",
  }

  # Checks if $http_proxy contains a string. If it is null, $proxy_uri is set to null.
  # Otherwise, it will concatenate $http_proxy and $proxy_port_string.
  $proxy_uri = $http_proxy ? {
    undef   => undef,
    default => "http://${http_proxy}${proxy_port_string}",
  }

  # Boolean parameter for class selection
  if $profiled { contain '::httpproxy::profiled' }
  if $packagemanager { contain '::httpproxy::packagemanager' }
  if $wget { contain '::httpproxy::wget' }
}
