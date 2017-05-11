#!/bin/bash

#
# Configuration file.
# 
# This file includes all the variables that are
# used throughout the setup script.


#
# Hadoop
#

# The hadoop version.
HADOOP_VERSION="2.7.2"

# The hadoop working directory (without the hadoop root).
# Must contain the trailing slash.
HADOOP_PWD="/opt/"

# The hadoop home directory. 
# Must not contain the trailing slash.
HADOOP_HOME="${HADOOP_PWD}hadoop"

#
# Users and groups.
#

# A common group shared by services.
HADOOP_GROUP="hadoop"

# User which will own the HDFS services.
HDFS_USER="hdfs"
# Home directory of the $HDFS_USER.
HDFS_USER_HOME="/home/$HDFS_USER"

# User which will own the YARN services.
YARN_USER="yarn"
# Home directory of the $YARN_USER.
YARN_USER_HOME="/home/$YARN_USER"

# User which will own the MapReduce services.
MAPRED_USER="mapred"
# Home directory of the $MAPRED_USER.
MAPRED_USER_HOME="/home/$MAPRED_USER"

#
# Hadoop Service - HDFS
#

# Space separated list of directories where NameNode will store file system image.
# For example, /grid/hadoop/hdfs/nn /grid1/hadoop/hdfs/nn
DFS_NAME_DIR="/hadoop/$HDFS_USER/nn"

# Space separated list of directories where DataNodes will store the blocks.
# For example, /grid/hadoop/hdfs/dn /grid1/hadoop/hdfs/dn
DFS_DATA_DIR="/hadoop/$HDFS_USER/dn"

# Directory to store the HDFS logs.
HDFS_LOG_DIR="/var/log/hadoop/$HDFS_USER"

# Directory to store the HDFS process ID.
HDFS_PID_DIR="/var/pid/hadoop/$HDFS_USER"

#
# Hadoop Service - YARN 
#

# Space separated list of directories where YARN will store temporary data.
# For example, /grid/hadoop/yarn/local /grid1/hadoop/yarn/local
YARN_LOCAL_DIR="/hadoop/$YARN_USER/local"

# Directory to store the YARN logs.
YARN_LOG_DIR="/var/log/hadoop/$YARN_USER"

# Space separated list of directories where YARN will store container log data.
# For example, /grid/hadoop/yarn/logs /grid1/hadoop/yarn/logs
YARN_LOCAL_LOG_DIR="/hadoop/$YARN_USER/logs"

# Directory to store the YARN process ID.
YARN_PID_DIR="/var/pid/hadoop/$YARN_USER"

#
# Hadoop Service - MAPREDUCE
#

# Directory to store the MapReduce daemon logs.
MAPRED_LOG_DIR="/var/log/hadoop/$MAPRED_USER"

# Directory to store the mapreduce jobhistory process ID.
MAPRED_PID_DIR="/var/pid/hadoop/$MAPRED_USER"
