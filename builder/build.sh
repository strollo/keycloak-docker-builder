#!/bin/bash -e

###########################
# Build/download Keycloak #
###########################

# Build
cd /opt/jboss/keycloak-source

echo "Running MVN compilation (this will take a lot of time ... be patient)"

$M2_HOME/bin/mvn -q --log-file dist/build.log -Pdistribution -pl distribution/server-dist -am -Dmaven.test.skip clean install

cd /opt/jboss

echo "Source can be found in /opt/jboss/keycloak-source/distribution/server-dist/target"

exit 0
