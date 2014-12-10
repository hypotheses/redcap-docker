#!/bin/sh

#------------------------------------------------------------------------------
# DESC: 
# Setup config (mostly hooking up the database container and processing
# some additional server reqirements of redcap) then execute the CMD transparently:

# AUTHOR: Amos Folarin <amosfolarin@gmail.com>

# USAGE: 
# [ENTRYPOINT] [CMD]
# parse_redcap_config.sh "/run.sh"
#------------------------------------------------------------------------------

#ENTRYPOINT param parsing for RedCap Container

#RUNTIME ENV VARS
REDCAP_DB_PORT_3306_TCP_ADDR_="" #The hostname of the linked database container
REDCAP_DB_NAME_="" #redcap database name created in mysql container
REDCAP_DB_USER_="" #redcap database user, not the default mysql container "admin" user which is overprivileged for redcap
REDCAP_DB_USER_PWD_="" #redcap database password
REDCAP_DB_SALT_="" #the >12 digit salt for the database

## check if each env var exists or exit
if [[ -z $REDCAP_DB_PORT_3306_TCP_ADDR ]]
then 
REDCAP_DB_PORT_3306_TCP_ADDR_=$REDCAP_DB_PORT_3306_TCP_ADDR
else
exit 1
fi

if [[ -z $REDCAP_DB_NAME]]
then
REDCAP_DB_NAME=$REDCAP_DB_NAME
else
exit 1
fi

if [[ -z $REDCAP_DB_USER]]
then
REDCAP_DB_USER_=$REDCAP_DB_USER
else
exit 1
fi

if [[ -z $REDCAP_DB_USER_PWD]]
then
REDCAP_DB_USER_PWD_=$REDCAP_DB_USER_PWD
else
exit 1
fi

if [[ -z $REDCAP_DB_SALT ]]
then
REDCAP_DB_SALT_==$REDCAP_DB_SALT
else
exit 1
fi

## Substitute env vars parsed at runtime into web-container:/app/redcap/database.php config file
sed -in -e s/your_mysql_host_name/\$REDCAP_DB_PORT_3306_TCP_ADDR_/ \
-e "s/your_mysql_db_name/\$REDCAP_DB_NAME_/" \
-e "s/your_mysql_db_username/\$REDCAP_DB_USER_/" \
-e "s/your_mysql_db_password/\$REDCAP_DB_USER_PWD_/" \
-e "s/\$salt = ''/\$salt = \$REDCAP_DB_SALT_/" \
/app/redcap/database.php

#Unset the password env var
REDCAP_DB_USER_PWD=""


# OTHER REDCAP CONFIG REQUIREMENTS
# postinstall checklist: http://localhost/redcap/redcap_v6.0.12/ControlCenter/check.php?upgradeinstall=1

## increase upload_max_filesize in php.ini
sed -in -e "s/upload_max_filesize = 2M/upload_max_filesize = 32M/" /etc/php5/apache2/php.ini

## uncomment max_input_vars in php.ini
sed -in -e "s/\; max_input_vars = 1000/max_input_vars = 1000/" /etc/php5/apache2/php.ini

## Mcrypt extenstion not installed - RECOMMENDED

## Missing UTF-8 fonts for PDF export - RECOMMENDED

## CRITICAL: setup cron, may require some supervisor?

## setup SMTP server for emails - CRITICAL

## Change default location for edocs folder - RECOMMENDED

## https + SSL certs strongly - CRITICAL



#LASTLY: execute the docker run CMD now
exec $CMD

