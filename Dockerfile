
FROM registry.access.redhat.com/ubi8-minimal AS basedist

ENV JDBC_POSTGRES_VERSION 42.2.5
ENV JDBC_MYSQL_VERSION 8.0.22
ENV JDBC_MARIADB_VERSION 2.5.4
ENV JDBC_MSSQL_VERSION 8.2.2.jre11

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak

ENV LANG en_US.UTF-8

USER root
RUN microdnf update -y && microdnf install -y glibc-langpack-en gzip hostname java-11-openjdk-headless openssl tar which && microdnf clean all


######################################################################################
# PHASE 1 - Take source from gitlab and store them in /opt/jboss/keycloak-source
######################################################################################
FROM basedist AS get_sources

ENV LANG en_US.UTF-8
USER root
RUN microdnf update -y && microdnf install -y git && microdnf clean all

ARG GIT_REPO=https://github.com/keycloak/keycloak
ARG GIT_BRANCH=main

RUN git clone --depth 1 $GIT_REPO.git -b $GIT_BRANCH /opt/jboss/keycloak-source


######################################################################################
# PHASE 2 - Take previously downloaded sources and compile then
# Once done a file will be produced as /dist/keycloak-*.tar.gz
######################################################################################
FROM basedist AS builder

COPY --from=get_sources /opt/jboss/keycloak-source /opt/jboss/keycloak-source

# Install Maven
RUN cd /opt/jboss && \
    curl -s https://apache.uib.no/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz | tar xz && \
    mv apache-maven-3.8.5 /opt/jboss/maven
ENV M2_HOME=/opt/jboss/maven

ADD ./builder/build.sh /opt/jboss/scripts/build.sh
RUN chmod +x /opt/jboss/scripts/build.sh
RUN /opt/jboss/scripts/build.sh


######################################################################################
# PHASE 3 - prepare runtime image with keycloak binaries shipped
######################################################################################
FROM basedist AS runtime

COPY --from=builder /opt/jboss/keycloak-source/distribution/server-dist/target/keycloak-*.tar.gz /opt/jboss/distrib/

ADD ./runtime/bin /opt/jboss/bin
RUN chmod +x /opt/jboss/bin/*.sh
ADD ./runtime/content/tools /opt/jboss/tools

RUN /opt/jboss/bin/init.sh
RUN chmod +x `find /opt/jboss/tools -name "*.sh"`

ENTRYPOINT ["/opt/jboss/tools/docker-entrypoint.sh"]
