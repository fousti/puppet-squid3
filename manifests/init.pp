# Define type: squid3
#
# Configure and run single squid instance 
#  
#  THIS MODULE REQUIRE SQUID 3.4 
#  HIS ONLY PURPOSE IS TO CONFIGURE AND RUN INSTANCE
#
#
# squid3 { "squid-hidden-fr" : 
#  http_port   => [5000],
#  cache_dir   => ['null /tmp/squid_hidden/'],
#  cache_peer  => ['0.0.0.0  parent 5000 0 proxy-only no-query round-robin login=login:pass',
#          '0.0.0.1  parent 5000 0 proxy-only no-query round-robin login=login:pass',
#          '0.0.0.2  parent 5000 0 proxy-only no-query round-robin login=login:pass',],
#  request_header_access => [  'From deny all',
#                'Server deny all',
#                'WWW-Authenticate deny all',
#                'Link deny all',
#                'Cache-Control deny all',
#                'Proxy-Connection deny all',
#                'X-Cache deny all',
#                'X-Cache-Lookup deny all',
#                'Via deny all',
#                'Forwarded-For deny all',
#                'X-Forwarded-For deny all',
#                'Pragma deny all',
#                'Keep-Alive deny all',],
#  user        => 'mrdrive',
#  password    => 'toto',

#} 
#
define squid3 (
  $http_port            = [],
  $http_access          = [],
  $request_header_access = [],
  $cache_dir            = [],
  $cache                = [],
  $cache_peer           = [],
  $via                  = 'off',
  $forwarded_for        = 'delete',
  $follow_x_forwarded_for = 'deny all',
  $config_hash          = {},
  $user                 = '',
  $password             = ''
) {

  # variable for log file in template 


  $access_log = "/var/log/squid/access_${name}.log"                     
  $cache_store_log = "/var/log/squid/cache_store_${name}.log"         
  $cache_log = "/var/log/squid/cache_${name}.log"                     



  #############################
  httpauth { $user :
    file     => "/etc/squid/${name}",
    password => $password,
    realm => 'realm',
    mechanism => basic,
    ensure  => present,
  }

  file { "/etc/squid/${name}" : 
    owner => proxy,
    group => proxy,
    require => Httpauth[$user]
  }

  file { "/var/run/${name}.pid" : 
    ensure => present,
    owner  => proxy,
    group  => proxy,
    mode   => 0644
  }

  file { $access_log : 
    ensure => present,
    owner  => proxy,
    group  => proxy,
    mode   => 0644
  }

  file { $cache_log : 
    ensure => present,
    owner  => proxy,
    group  => proxy,
    mode   => 0644
  }

  file { $cache_store_log : 
    ensure => present,
    owner  => proxy,
    group  => proxy,
    mode   => 0644
  }

  file { "/etc/squid/${name}.conf" :
    notify  => Service['squid3_service'],
    content => template('squid3/squid.conf.proxy.erb'),
    owner   => proxy,
    group   => proxy
  }

  service { 'squid3_service':
    enable    => true,
    name      => $name,
    ensure    => running,
    provider  => base,
    start     => "squid -f /etc/squid/${name}.conf",
    path      => ['/sbin', '/usr/sbin', '/usr/local/squid', '/usr/bin/', '/bin'],
    hasstatus => false,
    require   => [Httpauth[$user], File["/etc/squid/${name}.conf"], File[$cache_log], File[$access_log], File[$cache_store_log], File["/var/run/${name}.pid"]]
  }


}

