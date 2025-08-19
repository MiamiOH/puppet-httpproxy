# package/purge_apt_conf.pp (private class)
# Purges apt.conf
# Purges apt.conf to ensure proxy management is handled by the module.
# Dangerous! Don't use if you have settings in apt.conf
class httpproxy::package::purge_apt_conf {
  file { '/etc/apt/apt.conf':
    ensure => absent,
  }
}
