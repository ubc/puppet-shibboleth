# == Class: shibboleth::sp
#
# Installs shibboleth's service provider, and allow it's apache module get
# loaded with apache::module.
#
# Requires:
# - Class[apache]
#
# Limitations:
# - currently RedHat/CentOS only.
class shibboleth::sp (
    $idp_metadata_provider = undef,
    $idp_entity_id = undef,
    $force_authn = $shibboleth::sp::params::force_authn,
) inherits shibboleth::sp::params {

  yumrepo { 'security_shibboleth':
    descr    => "Shibboleth-RHEL_${::os_maj_version}",
    baseurl  => "http://download.opensuse.org/repositories/security://shibboleth/RHEL_${::os_maj_version}",
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth',
    enabled  => 1,
    gpgcheck => 1,
    require  => Exec['download shibboleth repo key'],
  }

  # ensure file is managed in case we want to purge /etc/yum.repos.d/
  # http://projects.puppetlabs.com/issues/3152
  file { '/etc/yum.repos.d/security_shibboleth.repo':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    require => Yumrepo['security_shibboleth'],
  }

  exec { 'download shibboleth repo key':
    command => "/usr/bin/curl -s http://download.opensuse.org/repositories/security:/shibboleth/RHEL_${::os_maj_version}/repodata/repomd.xml.key -o /etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth",
    creates => '/etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth',
    require => File['/etc/pki/rpm-gpg/'],
  }

  package { 'shibboleth':
    ensure  => present,
    name    => "shibboleth.${::architecture}",
    require => Yumrepo['security_shibboleth'],
  }

  $shibpath = $::architecture ? {
    x86_64 => '/usr/lib64/shibboleth/mod_shib_22.so',
    i386   => '/usr/lib/shibboleth/mod_shib_22.so',
  }

#  file { '/etc/httpd/mods-available/shib.load':
#    ensure  => present,
#    content => "# file managed by puppet\nLoadModule mod_shib ${shibpath}\n",
#  }

  file { '/etc/httpd/conf.d/shib.conf':
    ensure  => present,
    source  => 'puppet:///modules/shibboleth/shib.conf', 
    require => Package['shibboleth'],
    notify  => Service['httpd'],
  }

  file { '/etc/pki/rpm-gpg/':
    ensure => directory
  }

  file { '/etc/shibboleth/shibboleth2.xml':
    ensure => 'present',
    content => template('shibboleth/shibboleth2.xml.erb'),
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => [
      Package['shibboleth'],
    ],
    notify => Service['shibd'],
  }

  file { '/etc/shibboleth/attribute-map.xml':
    ensure => 'present',
    source => 'puppet:///modules/shibboleth/attribute-map.xml', 
    owner => 'root',
    group => 'root',
    mode => '0644',
    notify  => Service['httpd'],
  }
# TODO
##
## Used for example logo and style sheet in error templates.
##
#<IfModule mod_alias.c>
#  <Location /shibboleth-sp>
#    Allow from all
#  </Location>
#  Alias /shibboleth-sp/main.css /usr/share/doc/shibboleth/main.css
#  Alias /shibboleth-sp/logo.jpg /usr/share/doc/shibboleth/logo.jpg
#</IfModule>

}
