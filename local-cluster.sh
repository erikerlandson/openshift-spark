#!/bin/bash

opt/spark/bin/spark-shell --master "local-cluster[2,1,1024]" --conf spark.dynamicAllocation.enabled=true --conf spark.shuffle.service.enabled=true
