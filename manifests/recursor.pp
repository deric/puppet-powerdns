# @summary powerdns recursor

# @param package_ensure
# @param forward_zones Hash containing zone => dns servers pairs

class powerdns::recursor (
  $package_ensure      = $powerdns::params::default_package_ensure,
  Hash $forward_zones  = $powerdns::forward_zones,
  String $recursor_dir = $powerdns::recursor_dir,
) inherits powerdns {
  package { $powerdns::recursor_package:
    ensure => $package_ensure,
  }

  if !empty($forward_zones) {
    $zone_config = "${recursor_dir}/forward_zones.conf"
    file { $zone_config:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      content => template('powerdns/forward_zones.conf.erb'),
    }

    powerdns::config { 'forward-zones-file':
      value => $zone_config,
      type  => 'recursor',
    }
  }

  service { 'pdns-recursor':
    ensure   => running,
    name     => $::powerdns::params::recursor_service,
    enable   => true,
    provider => [$::powerdns::params::service_provider],
    require  => Package[$::powerdns::params::recursor_package],
  }
}
