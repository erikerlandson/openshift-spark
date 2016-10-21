FROM centos:latest

MAINTAINER Erik Erlandson <eje@redhat.com>

# when the containers are not run w/ uid 0, the uid may not map in
# /etc/passwd and it may not be possible to modify things like
# /etc/hosts. nss_wrapper provides an LD_PRELOAD way to modify passwd
# and hosts.
RUN yum install -y epel-release tar java && \
    yum install -y nss_wrapper && \
    yum clean all

# RUN cd /opt && \
#     curl https://dist.apache.org/repos/dist/release/spark/spark-2.0.0/spark-2.0.0-bin-hadoop2.7.tgz | \
#        tar -zx && \
#    ln -s spark-2.0.0-bin-hadoop2.7 spark

COPY spark-distro.tgz /opt/spark/

RUN cd /opt/spark && tar --strip-components=1 -xzf spark-distro.tgz && rm spark-distro.tgz

ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark

# Add scripts used to configure the image
COPY scripts /tmp/scripts/

RUN bash -x /tmp/scripts/spark/install && rm -rf /tmp/scripts

# Switch to the user 185 for OpenShift usage
# USER 185

# Start the main process
# CMD ["/opt/spark/bin/launch.sh"]
