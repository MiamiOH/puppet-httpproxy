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
#   Configure profiled module to configure proxy on host (default: true)
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
  # No proxy host means all managed proxy configuration should be removed.
  $ensure = $http_proxy ? {
    undef   => 'absent',
    default => 'present',
  }

  # Build the optional port portion of the proxy URI.
  $proxy_port_string = $http_proxy_port ? {
    undef   => undef,
    default => ":${http_proxy_port}",
  }

  # Build the complete proxy URI.
  $proxy_uri = $http_proxy ? {
    undef   => undef,
    default => "http://${http_proxy}${proxy_port_string}",
  }

  # Always declare these classes so that changing a feature from
  # true -> false removes configuration previously managed by Puppet.
  contain 'httpproxy::profiled'
  contain 'httpproxy::packagemanager'
  contain 'httpproxy::wget'
}
