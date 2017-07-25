#/bin/bash

set -v

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
