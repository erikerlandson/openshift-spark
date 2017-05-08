FROM centos:latest

MAINTAINER Erik Erlandson <eje@redhat.com>

USER root
ARG DISTRO_TAR
ARG DISTRO_NAME

RUN yum install -y epel-release tar java && \
    yum clean all

# when the containers are not run w/ uid 0, the uid may not map in
# /etc/passwd and it may not be possible to modify things like
# /etc/hosts. nss_wrapper provides an LD_PRELOAD way to modify passwd
# and hosts.
RUN yum install -y nss_wrapper numpy && yum clean all

COPY $DISTRO_TAR /opt/
RUN cd /opt && tar xzf $DISTRO_TAR && ln -s $DISTRO_NAME spark && rm $DISTRO_TAR

ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark
ENV JAVA_HOME=/usr

# Add scripts used to configure the image
COPY scripts /tmp/scripts

# Custom scripts
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

# Cleanup the scripts directory
RUN rm -rf /tmp/scripts

# Switch to the user 185 for OpenShift usage
USER 185

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
WORKDIR /tmp

ENTRYPOINT ["/entrypoint"]

# Start the main process
CMD ["/opt/spark/bin/launch.sh"]
