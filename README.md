## Apache Spark images for OpenShift

This branch is a customized variation that builds a driver image and executor image configured to run with the
[Kubernetes-native Apache Spark project](https://github.com/apache-spark-on-k8s/spark)

#### Build kube-native spark distribution

```bash
% cd /path/to/spark
# This is head of k8s-native for spark 2.1 series.  Note, there is now also branch-2.2-kubernetes
% checkout branch-2.1-kubernetes
% dev/make-distribution.sh --tgz -Phadoop-2.7 -Pkubernetes
# The name of the generated tarball may vary.
# Recommend to run submission client against this tarball.
% tar xzf spark-2.1.0-k8s-0.3.0-SNAPSHOT-bin-2.7.3.tgz
```

#### Build images

```bash
% cd /path/to/openshift-spark
# To get this branch, fetch from: https://github.com/erikerlandson/openshift-spark
% checkout k8s-native-v2
# note your path and distro name may differ:
% make DISTRO_PATH=/path/to/spark DISTRO_NAME=spark-2.1.0-k8s-0.3.0-SNAPSHOT-bin-2.7.3 push
```

You should now have images like `manyangled/k8s-native-v2-driver:latest` and `manyangled/k8s-native-v2-executor:latest`.
The docker repo remote, tag, etc, can be controlled as parameters to the makefile, if desired.
(Look at top of Makefile to see the parameters)

#### Configure openshift cluster

Example of how to get it working from `oc cluster up`:

```bash
% oc cluster up
# You need a service-account to give to spark-submit client:
% oc create sa spark && oc policy add-role-to-group admin system:serviceaccounts:myproject
# Current default logic requires this to get node info (do this as admin):
% oadm policy add-cluster-role-to-user cluster-reader developer
# start up staging server pod (edit yaml with your image names, if needed)
% oc create -f /path/to/openshift-spark/kubernetes-resource-staging-server.yaml
# get a node IP on your cluster
% oc get nodes
```

#### Submit a job

Example SparkPi submission:
The IP used in the staging server URI comes from 'get nodes' above

```bash
# Assumes running from untarred distribution tarball, created above
bin/spark-submit \
  --deploy-mode cluster \
  --class org.apache.spark.examples.SparkPi \
  --master k8s://192.168.1.125:8443 \
  --kubernetes-namespace myproject \
  --conf spark.executor.instances=2 \
  --conf spark.app.name=spark-pi \
  --conf spark.kubernetes.driver.docker.image=manyangled/k8s-native-v2-driver:latest \
  --conf spark.kubernetes.executor.docker.image=manyangled/k8s-native-v2-executor:latest \
  --conf spark.kubernetes.initcontainer.docker.image=manyangled/k8s-native-v2-init-container:latest \
  --conf spark.kubernetes.resourceStagingServer.uri=http://192.168.1.125:31000 \
  examples/jars/spark-examples_2.11-2.1.0-k8s-0.3.0-SNAPSHOT.jar
```

See here for more details and parameters pertaining to running kube-native spark:
https://apache-spark-on-k8s.github.io/userdocs/running-on-kubernetes.html
