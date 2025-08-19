# @summary configures the httpproxy module
#
# @example Basic usage
#   class { 'httpproxy':
#     http_proxy      => 'proxy.host.com',
#     http_proxy_port => 80,
#     no_proxy        => 'dont.proxy.this.host.com',
#     profiled        => true,
#     packagemanager  => true,
#     wget            => false,
#     purge_apt_conf  => false,
#   }
#
# @see https://github.com/MiamiOH/puppet-httpproxy
#
# @param http_proxy
#   DNS Name or IP address for proxy host
# @param http_proxy_port
#   Proxy host port
# @param no_proxy
#   Comma separated string of hosts to access without using proxy
# @param profiled
#   Use profiled module to configure proxy on host (default: true)
# @param packagemanager
#   Configure package manager to use proxy (default: true)
# @param wget
#   Configure wget to use proxy (default: false)
# @param purge_apt_conf
#   Whether or not to purge the apt configuration (default: false)

class httpproxy (
  Optional[Stdlib::Host] $http_proxy      = undef,
  Optional[Stdlib::Port] $http_proxy_port = undef,
  Optional[String]       $no_proxy        = undef,
  Boolean                $profiled        = true,
  Boolean                $packagemanager  = true,
  Boolean                $wget            = false,
  Boolean                $purge_apt_conf  = false,
) {
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
  if $profiled { contain 'httpproxy::profiled' }
  if $packagemanager { contain 'httpproxy::packagemanager' }
  if $wget { contain 'httpproxy::wget' }
}
