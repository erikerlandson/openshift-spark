[![Build status](https://travis-ci.org/radanalyticsio/openshift-spark.svg?branch=master)](https://travis-ci.org/radanalyticsio/openshift-spark)
[![Docker build](https://img.shields.io/docker/automated/radanalyticsio/openshift-spark.svg)](https://hub.docker.com/r/radanalyticsio/openshift-spark)

## Apache Spark images for OpenShift

This branch is a customized variation that builds a driver image and executor image configured to run with the
[Kubernetes-native Apache Spark project](https://github.com/apache-spark-on-k8s/spark)

#### Build kube-native spark distribution

```bash
% cd /path/to/spark
# This is head of k8s-native dev.
# Other build tags include: v2.1.0-kubernetes-0.1.0-alpha.2 or v2.1.0-kubernetes-0.1.0-rc1
# to get these, fetch from: https://github.com/apache-spark-on-k8s/spark
% checkout branch-2.1-kubernetes
% dev/make-distribution.sh --tgz -Phadoop-2.7 -Pkubernetes
# The name of the generated tarball may vary.
# Recommend to run submission client against this tarball.
% tar xzf spark-2.1.0-k8s-0.1.0-SNAPSHOT-bin-2.7.3.tgz
```

#### Build images

```bash
% cd /path/to/openshift-spark
# To get this branch, fetch from: https://github.com/erikerlandson/openshift-spark
% checkout k8s-native
% note your path and distro name may differ:
% make DISTRO_PATH=/home/eje/git/spark DISTRO_NAME=spark-2.1.0-k8s-0.1.0-SNAPSHOT-bin-2.7.3 push
```

You should now have images like `manyangled/k8s-native-driver:latest` and `manyangled/k8s-native-executor:latest`.
The docker repo remote, tag, etc, can be controlled as parameters to the makefile, if desired.
(Look at top of Makefile to see the parameters)

#### Configure openshift cluster

Example of how to get it working from `oc cluster up`:

```bash
% oc cluster up
# You need a service-account to give to spark-submit client:
% oc create sa spark && oc policy add-role-to-group admin system:serviceaccounts:myproject
# Current default logic requires this to get node info
# (I expect this to become obsolete with new "v2" independent file staging server)
# (do this as user system:admin)
% oadm policy add-cluster-role-to-user cluster-reader developer
```

#### Submit a job

Example SparkPi submission:

```bash
# Assumes running from untarred distribution tarball, created above
% bin/spark-submit \
  --deploy-mode cluster \
  --class org.apache.spark.examples.SparkPi \
  --master k8s://https://10.0.1.36:8443 \
  --conf spark.executor.instances=2 \
  --conf spark.app.name=spark-pi \
  --conf spark.kubernetes.driver.docker.image=manyangled/k8s-native-driver:latest \
  --conf spark.kubernetes.executor.docker.image=manyangled/k8s-native-executor:latest \
  --conf spark.kubernetes.namespace=myproject \
  --conf spark.kubernetes.submit.serviceAccountName=spark \
  examples/jars/spark-examples_2.11-2.1.0-k8s-0.1.0-SNAPSHOT.jar
```

See here for more details and parameters pertaining to running kube-native spark:
https://github.com/apache-spark-on-k8s/spark/blob/branch-2.1-kubernetes/docs/running-on-kubernetes.md
