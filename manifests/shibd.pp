#
# == Class: shibboleth::shibd
#
# Enables the shibd daemon.
#
# Requires:
# - Class[shibboleth::sp]
# - selinux module
#
class shibboleth::shibd {

  user { 'shibd':
    require => Package[ 'shibboleth' ],
  }

  service { 'shibd':
    ensure  => running,
    enable  => true,
    require => Package[ 'shibboleth' ],
  }

  # apache must be able to connect to shibd's socket.
  if $::selinux {

    file { '/var/run/shibboleth/':
      ensure  => 'directory',
      owner   => 'shibd',
      group   => 'shibd',
      seltype => 'httpd_var_run_t',
      notify  => Service[ 'shibd' ],
      require => Package[ 'shibboleth' ],
    }

    selinux::module { 'shibd':
      source => "puppet:///modules/shibboleth/shibd",
    }
  }

  file { '/var/log/shibboleth':
    ensure => 'directory',
    owner  => 'shibd',
    group  => 'shibd',
    mode   => '0750',
  }

  $shibd_local_config_file = $::osfamily ? {
    'RedHat' => '/etc/sysconfig/shibd',
    'Debian' => '/etc/default/shibd',
  }

  augeas { 'set shibd user':
    incl    => $shibd_local_config_file,
    lens    => 'Shellvars.lns',
    changes => 'set SHIBD_USER shibd',
    notify  => Service['shibd'],
  }

}
