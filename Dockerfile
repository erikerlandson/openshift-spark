FROM centos:latest

MAINTAINER Matthew Farrellee <matt@cs.wisc.edu>

RUN yum install -y epel-release tar java && \
    yum clean all

#RUN cd /opt && \
#    curl https://dist.apache.org/repos/dist/release/spark/spark-2.0.0-preview/spark-2.0.0-preview-bin-hadoop2.7.tgz | \
#        tar -zx && \
#    ln -s spark-2.0.0-preview-bin-hadoop2.7 spark

ADD spark-2.0.1-scorpion-stare-SNAPSHOT-bin-2.2.0.tgz /opt
RUN cd /opt && ln -s spark-2.0.1-scorpion-stare-SNAPSHOT-bin-2.2.0 spark
RUN cd /opt && rm -f spark-2.0.1-scorpion-stare-SNAPSHOT-bin-2.2.0.tgz 

# worker scaling plugins
COPY scorpion_stare.jar /opt/spark/jars

# SPARK_WORKER_DIR defaults to SPARK_HOME/work and is created on
# Worker startup if it does not exist. instead of making SPARK_HOME
# world writable, create SPARK_HOME/work.
RUN mkdir /opt/spark/work && chmod a+rwx /opt/spark/work
RUN mkdir /opt/spark/logs && chmod a+rwx /opt/spark/logs

# when the containers are not run w/ uid 0, the uid may not map in
# /etc/passwd and it may not be possible to modify things like
# /etc/hosts. nss_wrapper provides an LD_PRELOAD way to modify passwd
# and hosts.
RUN yum install -y nss_wrapper && yum clean all
ENV LD_PRELOAD=libnss_wrapper.so

ENV PATH $PATH:/opt/spark/bin
ENV SPARK_HOME /opt/spark
ENV SPARK_CONF_DIR /opt/spark/conf

# Set limit on the resources each worker consumes
ENV SPARK_WORKER_CORES 1
ENV SPARK_WORKER_MEMORY 1g

COPY spark-defaults.conf /opt/spark/conf
RUN chmod a+r /opt/spark/conf/spark-defaults.conf

COPY common.sh start-master start-worker local-cluster.sh /
RUN chmod a+rx /common.sh /start-master /start-worker /local-cluster.sh
