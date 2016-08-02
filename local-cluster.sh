#!/bin/bash

$SPARK_HOME/sbin/start-shuffle-service.sh

$SPARK_HOME/bin/spark-shell --master "local-cluster[2,1,1024]"

#opt/spark/bin/spark-shell --master "local-cluster[2,1,1024]" --conf spark.dynamicAllocation.enabled=true --conf spark.shuffle.service.enabled=true

# --conf spark.dynamicAllocation.sustainedSchedulerBacklogTimeout=30
