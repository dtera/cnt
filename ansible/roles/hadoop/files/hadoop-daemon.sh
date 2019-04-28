#!/usr/bin/env bash

hadoop_home=/usr/local/cnt/hadoop-3.2.0
${hadoop_home}/bin/hdfs --daemon $1 $2