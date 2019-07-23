#!/bin/bash
#THIS SCRIPT NEED TO RUN IN NODE TO INSERT datasource AND security-domain VALUES #
##################################################################################

# Variables
ToFILE=$1
jta=$2
jndiname=$3
poolname=$4
enabled=$5
useccm=$6
statisticsenabled=$7
connectionurl=$8
driverclass=$9
driver=${10}
minpoolsize=${11}
maxpoolsize=${12}
securitydomain=${13}
validationclassname=${14}
checkvalidconnectionsql=${15}
validateonmatch=${16}
backgroundvalidation=${17}
backgroundvalidationmillis=${18}
exceptionsorterclassname=${19}
settxquerytimeout=${20}
blockingtimeoutmillis=${21}
idletimeoutminutes=${22}
querytimeout=${23}
usetrylock=${24}
allocationretry=${25}
allocationretrywaitmillis=${26}
sharepreparedstatements=${27}
username=${28}
password=${29}

# Validate input
if [[ -z $ToFILE ]] || [[ -z $jta ]] || [[ -z $jndiname ]] || [[ -z $poolname ]] || [[ -z $enabled ]] || [[ -z $useccm ]] || [[ -z $statisticsenabled ]] || [[ -z $connectionurl ]] || [[ -z $driverclass ]] || [[ -z $driver ]] || [[ -z $minpoolsize ]] || [[ -z $maxpoolsize ]] || [[ -z $securitydomain ]] || [[ -z $validationclassname ]] || [[ -z $checkvalidconnectionsql ]] || [[ -z $validateonmatch ]] || [[ -z $backgroundvalidation ]] || [[ -z $backgroundvalidationmillis ]] || [[ -z $exceptionsorterclassname ]] || [[ -z $settxquerytimeout ]] || [[ -z $blockingtimeoutmillis ]] || [[ -z $idletimeoutminutes ]] || [[ -z $querytimeout ]] || [[ -z $usetrylock ]] || [[ -z $allocationretry ]] || [[ -z $allocationretrywaitmillis ]] || [[ -z $sharepreparedstatements ]] || [[ -z $username ]] || [[ -z $password ]]; then 
   echo -e "Please pass all variable inputs "
   exit 0
fi 

# get current line number datasources
matchLineNoDC=$(grep -in '</datasource>' ${ToFILE} | tail -1 | awk -F: '{print $1+1}')

insertDataSource="\               <datasource jta=\"$jta\" jndi-name=\"$jndiname\" pool-name=\" $poolname\" enabled=\"$enabled\" use-ccm=\"$useccm\" statistics-enabled=\"$statisticsenabled\">\n                 <connection-url>$connectionurl</connection-url>\n                    <driver-class>$driverclass</driver-class>\n                     <driver>$driver</driver>\n                      <pool>\n                        <min-pool-size>$minpoolsize</min-pool-size>\n                       <max-pool-size>$maxpoolsize</max-pool-size>\n                      </pool>\n                      <security>\n                        <security-domain>$securitydomain</security-domain>\n                      </security>\n                      <validation>\n                       <valid-connection-checker class-name=\"$validationclassname\"/>\n                       <check-valid-connection-sql>$checkvalidconnectionsql</check-valid-connection-sql>\n                       <validate-on-match>$validateonmatch</validate-on-match>\n                       <background-validation>$backgroundvalidation</background-validation>\n                        <background-validation-millis>$backgroundvalidationmillis</background-validation-millis>\n                        <exception-sorter class-name=\"$exceptionsorterclassname\"/>\n                      </validation>\n                      <timeout>\n                        <set-tx-query-timeout>$settxquerytimeout</set-tx-query-timeout>\n                       <blocking-timeout-millis>$blockingtimeoutmillis</blocking-timeout-millis>\n                       <idle-timeout-minutes>$idletimeoutminutes</idle-timeout-minutes>\n                        <query-timeout>$querytimeout</query-timeout>\n                        <use-try-lock>$usetrylock</use-try-lock>\n                        <allocation-retry>$allocationretry</allocation-retry>\n                       <allocation-retry-wait-millis>$allocationretrywaitmillis</allocation-retry-wait-millis>\n                      </timeout>\n                      <statement>\n                        <share-prepared-statements>$sharepreparedstatements</share-prepared-statements>\n                      </statement>\n                   </datasource> "

# Insert at specific line in datasources
if [[ ! -z $matchLineNoDC ]] && [[ ! -z $insertDataSource ]]; then 
    echo -e "Add datasource: $insertDataSource"
    sed -i "${matchLineNoDC}i${insertDataSource}" ${ToFILE}
else 
    echo -e "Error to update datasource in $ToFILE"
    exit 0 
fi

## security-domains
matchLineNoSD=$(grep -in '</security-domain>' ${ToFILE} | tail -1 | awk -F: '{print $1+1}')

insertSecurityDomain="\               <security-domain name=\"$securitydomain\">\n                  <authentication>\n                  <login-module code=\"org.picketbox.datasource.security.SecureIdentityLoginModule\" flag=\"required\">\n                   <module-option name=\"username\" value=\"$username\"/>\n                    <module-option name=\"password\" value=\"$password\"/>\n                    </login-module>\n                 </authentication>\n                </security-domain>"

 #Insert at specific line in security-domains
if [[ ! -z $matchLineNoSD ]] && [[ ! -z $insertSecurityDomain ]]; then
    echo -e "add security-domain: $insertSecurityDomain" 
    sed -i "${matchLineNoSD}i${insertSecurityDomain}" ${ToFILE}
else 
    echo -e "Error to update security-domain in $ToFILE"
    exit 0
fi

## END ##
