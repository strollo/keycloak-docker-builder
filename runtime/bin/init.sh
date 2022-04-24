#!/bin/bash -e

echo "Installing release"
cd /opt/jboss/
tar -zxvf distrib/keycloak-*.tar.gz
if [[ "$?" != "0" ]] ; then
   echo "Cannot extract binaries... exiting"
   exit 1
fi

mv /opt/jboss/keycloak-* /opt/jboss/keycloak

rm -f /opt/jboss/distrib/keycloak-*.tar.gz

#####################
# Create DB modules #
#####################
echo "Initializing DB modules"

mkdir -p /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main
cd /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main
curl -O https://repo1.maven.org/maven2/mysql/mysql-connector-java/$JDBC_MYSQL_VERSION/mysql-connector-java-$JDBC_MYSQL_VERSION.jar
cp /opt/jboss/tools/databases/mysql/module.xml .
sed "s/JDBC_MYSQL_VERSION/$JDBC_MYSQL_VERSION/" /opt/jboss/tools/databases/mysql/module.xml > module.xml

mkdir -p /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main
cd /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main
curl -L https://repo1.maven.org/maven2/org/postgresql/postgresql/$JDBC_POSTGRES_VERSION/postgresql-$JDBC_POSTGRES_VERSION.jar > postgres-jdbc.jar
cp /opt/jboss/tools/databases/postgres/module.xml .

mkdir -p /opt/jboss/keycloak/modules/system/layers/base/org/mariadb/jdbc/main
cd /opt/jboss/keycloak/modules/system/layers/base/org/mariadb/jdbc/main
curl -L https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/$JDBC_MARIADB_VERSION/mariadb-java-client-$JDBC_MARIADB_VERSION.jar > mariadb-jdbc.jar
cp /opt/jboss/tools/databases/mariadb/module.xml .

mkdir -p /opt/jboss/keycloak/modules/system/layers/base/com/oracle/jdbc/main
cd /opt/jboss/keycloak/modules/system/layers/base/com/oracle/jdbc/main
cp /opt/jboss/tools/databases/oracle/module.xml .

mkdir -p /opt/jboss/keycloak/modules/system/layers/keycloak/com/microsoft/sqlserver/jdbc/main
cd /opt/jboss/keycloak/modules/system/layers/keycloak/com/microsoft/sqlserver/jdbc/main
curl -L https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/$JDBC_MSSQL_VERSION/mssql-jdbc-$JDBC_MSSQL_VERSION.jar > mssql-jdbc.jar
cp /opt/jboss/tools/databases/mssql/module.xml .

######################
# Configure Keycloak #
######################

cd /opt/jboss/keycloak

bin/jboss-cli.sh --file=/opt/jboss/tools/cli/standalone-configuration.cli
rm -rf /opt/jboss/keycloak/standalone/configuration/standalone_xml_history

bin/jboss-cli.sh --file=/opt/jboss/tools/cli/standalone-ha-configuration.cli
rm -rf /opt/jboss/keycloak/standalone/configuration/standalone_xml_history

###########
# Garbage #
###########

rm -rf /opt/jboss/keycloak/standalone/tmp/auth
rm -rf /opt/jboss/keycloak/domain/tmp/auth

###################
# Set permissions #
###################

echo "jboss:x:0:root" >> /etc/group
echo "jboss:x:1000:0:JBoss user:/opt/jboss:/sbin/nologin" >> /etc/passwd
chown -R jboss:root /opt/jboss
chmod -R g+rwX /opt/jboss
