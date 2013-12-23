define shibboleth::sp::resource (
  $shib_conf,
  $location = $name,
  $require_session = 1,
  $location_require = 'valid-user',
) {
  concat::fragment{"shib_conf_${name}":
    target  => $shib_conf,
    content => template('shibboleth/protected_resource.conf.erb'),
  }
}
