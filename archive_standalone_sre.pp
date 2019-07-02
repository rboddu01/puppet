###
# Description: This manifest is to manage standalone-full-ha.xml file
###

class jboss::archive_standalone_sre (
  $security_realm_name                = 'security_realm_name',
  $security_realms_properties_path    = $jboss::security_realms_properties_path,
  $security_realms_relative_to        = $jboss::security_realms_relative_to

) {
  file { [ "/opt/eap7/sre/configuration/dep_valid/deployments.xml" ]:
  audit  => 'content',
  notify => Exec["standalone-full-ha_final_source.xml"],
  }

  # This is to create deployments.xml file.
  # Deployment Entries from existing standalone-full-ha.xml file are captured,
  # and passed as content to deployments.xml file
  exec { 'deployments.xml':
    command     => "sed -n '/<deployments>/,/<\\/deployments>/p' standalone-full-ha.xml > dep_valid/deployments.xml",
    user        => $jboss::user,
    path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    cwd         => "${jboss::install_path}/${jboss::app_module}/configuration",
    #refreshonly => true,
  }
 
  # This is to create standalone-full-ha_prime_source.xml file based on pre-defined template
  file { "${jboss::install_path}/${jboss::app_module}/configuration/dep_valid/standalone-full-ha_prime_source.xml":
    ensure  => 'present',
    mode    => '0755',
    owner   => $jboss::user,
    replace => false,
    content => template("${module_name}/sre-standalone-full-ha_prime_source.xml.erb"),
    require =>  Exec['deployments.xml'],
  }

  # This is to update standalone-full-ha.xml file based on standalone-full-ha_prime_source.xml and deployments.xml
  exec { 'standalone-full-ha_final_source.xml':
   command    => "sed -e '/<!--deployments-->/r deployments.xml' standalone-full-ha_prime_source.xml > ../standalone-full-ha.xml",
   user        => $jboss::user,
   cwd         => "${jboss::install_path}/${jboss::app_module}/configuration/dep_valid",
   path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
   require     => File["${jboss::install_path}/${jboss::app_module}/configuration/dep_valid/standalone-full-ha_prime_source.xml"],
   refreshonly => true,
  }

  # This is to copy standalone-full-ha.xml_updates.sh script to node dep_valid folder:
  file { "${jboss::install_path}/${jboss::app_module}/configuration/dep_valid/standalone-full-ha.xml_updates.sh":
    source  => "puppet:///modules/${module_name}/standalone-full-ha.xml_updates.sh",
    mode    => '0755',
    require => Exec["standalone-full-ha_final_source.xml"],
  }
}

## END 

#This calss is to Create a datasource tag in standalone-full-ha.xml File
#This Run's the standalone-full-ha.xml_updates.sh script,remotly
class jboss::archive_standalone_sre::datasource00(
$jta = true,
$jndi_name = undef,
$pool_name = undef,
$enabled = true,
$use_ccm = true,
$statistics_enabled = false,
$connection_url = undef,
$driver_class = 'oracle.jdbc.OracleDriver',
$driver = 'dhw.com.oracle',
$min_pool_size = 25,
$max_pool_size = 100,
$security_domain = undef,
$validation_class_name = 'org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker',
$check_valid_connection_sql = 'SELECT 1 FROM DUAL',
$validate_on_match = true,
$background_validation = false,
$background_validation_millis = 100,
$exception_sorter_class_name = 'org.jboss.jca.adapters.jdbc.extensions.oracle.OracleExceptionSorter',
$set_tx_query_timeout = false,
$blocking_timeout_millis = 0,
$idle_timeout_minutes = 5,
$query_timeout = 0,
$use_try_lock = 0,
$allocation_retry = 0,
$allocation_retry_wait_millis = 0,
$share_prepared_statements = false,
$username = 'IWS_SIMULATOR_USER',
$password = undef,
) {

if $jndi_name and $pool_name and $connection_url and $driver_class and $driver and $security_domain and $validation_class_name and $check_valid_connection_sql and $exception_sorter_class_name and $username and $password {

  $toFile = "${jboss::install_path}/${jboss::app_module}/configuration/standalone-full-ha.xml"

  $cmd = "sh ${jboss::install_path}/${jboss::app_module}/configuration/dep_valid/standalone-full-ha.xml_updates.sh \'${toFile}\' \'${jta}\' \'${jndi_name}\' \'${pool_name}\' \'${enabled}\' \'${use_ccm}\' \'${statistics_enabled}\' \'${connection_url}\' \'${driver_class}\' \'${driver}\' \'${min_pool_size}\' \'${max_pool_size}\' \'${security_domain}\' \'${validation_class_name}\' \'${check_valid_connection_sql}\' \'${validate_on_match}\' \'${background_validation}\' \'${background_validation_millis}\' \'${exception_sorter_class_name}\' \'${set_tx_query_timeout}\' \'${blocking_timeout_millis}\' \'${idle_timeout_minutes}\' \'${query_timeout}\' \'${use_try_lock}\' \'${allocation_retry}\' \'${allocation_retry_wait_millis}\' \'${share_prepared_statements}\' \'${username}\' \'${password}\'"

  #notify {"hello ----- $cmd ":}

  Exec { path =>  ['/bin/', '/sbin', '/usr/bin/', '/usr/sbin/'] }
  exec { $cmd:
    unless   => "grep -i \"datasource.*.jndi-name.*.${jndi_name}.*\" $toFile",
    # require  => [ Exec['standalone-full-ha_final_source.xml'], File['/opt/jboss/configuration/dep_valid/standalone-full-ha.xml_updates.sh' ] ],
  }
} else {
  fail("Please provide all variables.")
}
}

## END ##
#This calss is to Create a second datasource tag in standalone-full-ha.xml File
#This Run's the standalone-full-ha.xml_updates.sh script,remotly
class jboss::archive_standalone_sre::datasource01(
$jta = true,
$jndi_name = undef,
$pool_name = undef,
$enabled = true,
$use_ccm = true,
$statistics_enabled = false,
$connection_url = undef,
$driver_class = 'oracle.jdbc.OracleDriver',
$driver = 'dhw.com.oracle',
$min_pool_size = 25,
$max_pool_size = 100,
$security_domain = undef,
$validation_class_name = 'org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker',
$check_valid_connection_sql = 'SELECT 1 FROM DUAL',
$validate_on_match = true,
$background_validation = false,
$background_validation_millis = 100,
$exception_sorter_class_name = 'org.jboss.jca.adapters.jdbc.extensions.oracle.OracleExceptionSorter',
$set_tx_query_timeout = false,
$blocking_timeout_millis = 0,
$idle_timeout_minutes = 5,
$query_timeout = 0,
$use_try_lock = 0,
$allocation_retry = 0,
$allocation_retry_wait_millis = 0,
$share_prepared_statements = false,
$username = 'IWS_SIMULATOR_USER',
$password = undef,
) {

if $jndi_name and $pool_name and $connection_url and $driver_class and $driver and $security_domain and $validation_class_name and $check_valid_connection_sql and $exception_sorter_class_name and $username and $password {

  $toFile = "${jboss::install_path}/${jboss::app_module}/configuration/standalone-full-ha.xml"

  $cmd = "sh ${jboss::install_path}/${jboss::app_module}/configuration/dep_valid/standalone-full-ha.xml_updates.sh  \'${toFile}\' \'${jta}\' \'${jndi_name}\' \'${pool_name}\' \'${enabled}\' \'${use_ccm}\' \'${statistics_enabled}\' \'${connection_url}\' \'${driver_class}\' \'${driver}\' \'${min_pool_size}\' \'${max_pool_size}\' \'${security_domain}\' \'${validation_class_name}\' \'${check_valid_connection_sql}\' \'${validate_on_match}\' \'${background_validation}\' \'${background_validation_millis}\' \'${exception_sorter_class_name}\' \'${set_tx_query_timeout}\' \'${blocking_timeout_millis}\' \'${idle_timeout_minutes}\' \'${query_timeout}\' \'${use_try_lock}\' \'${allocation_retry}\' \'${allocation_retry_wait_millis}\' \'${share_prepared_statements}\' \'${username}\' \'${password}\'"

  #notify {"hello ----- $cmd ":}

  Exec { path =>  ['/bin/', '/sbin', '/usr/bin/', '/usr/sbin/'] }
  exec { $cmd:
    unless   => "grep -i \"datasource.*.jndi-name.*.${jndi_name}.*\" $toFile",
    # require  => [ Exec['standalone-full-ha_final_source.xml'], File['/opt/eap7/sre/configuration/dep_valid/standalone-full-ha.xml_updates.sh'] ]
  }
} else {
  fail("Please provide all variables.")
}
}
## END ##
