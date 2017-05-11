#!/bin/bash

# @todo: To be removed. Only for debugging purposes.
if [[ -z ${BOOTSTRAPPED} ]] ; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source ${DIR}/../settings.sh
    source ${DIR}/../bash_common_helpers/bash-common-helpers.sh
fi

# Function check_bootstrapped
#
# Checks if the bootstrapped variable is empty.
# If empty, it means that the bootstrap.sh has not been sourced.
# In that case, exit since none of the necessary variables are initialized.
function check_bootstrapped {
    if [[ -z ${BOOTSTRAPPED} ]] ; then
        echo "The script has not been bootstraped. Please, source the boostrap before executing the script."
        exit -1;
    fi
}

#
# Helper hadoop functions.
#

# Add the java repor and update.
function update_apt_repo  {
  sudo add-apt-repository ppa:webupd8team/java
  sudo apt-get update
}

# Install oracle java and setup variables.
function install_java {
  sudo apt-get install oracle-java8-installer
  sudo apt-get install oracle-java8-set-default

  if [[ -z ${JAVA_HOME} ]] ; then
    export_java_home
  fi
}

# Exports the java home setup to a profile configuration.
function export_java_home {
    JAVA_HOME="$JAVA_HOME" # get java home from current user's environment
    echo "Setting Java Home:> $JAVA_HOME"
    sudo sh -c "echo export JAVA_HOME=$JAVA_HOME > /etc/profile.d/java.sh"
    #To make sure JAVA_HOME is defined for this session, source the new script:
    source /etc/profile.d/javal.sh
}

# Create users to own the hdfs, yarn and mapred services.
# Create hadoop group.
# @todo: What if we don't want all the users/services?
# @see: /settings.sh
# @see: /scripts/user_setup.sh
function setup_hadoop_users {
    check_bootstrapped
    echo "Create the hadoop group"
    create_hadoop_group ${HADOOP_GROUP}
    echo "Create user hdfs"
    create_hadoop_user ${HDFS_USER} ${HDFS_USER_HOME}
    echo "Create user yarn"
    create_hadoop_user ${YARN_USER} ${YARN_USER_HOME}
    echo "Create user mapred"
    create_hadoop_user ${MAPRED_USER} ${MAPRED_USER_HOME}
}

# Function create_hdoop_group.
#
# Takes 1 argument, the group name.
# Creates a group to the system if it does not exist.
# If the group already exists, the function simply skips.
#
# Example: create_hadoop_group hadoop
#
function create_hadoop_group {
	local group=$1
	if [[ `groups | grep -c ${group}` -eq 1 ]] ; then
		echo "${group} group already exists. Skipping."
		return;
	fi

	echo "Create group hadoop"
	sudo groupadd ${group}
	echo ""
} 

# Function create_hadoop_user
#
# Generates a user, sets up the home directory and the
# skeleton files and creates a private key for the user.
#
# Example: create_hadoop_user hduser /home/hduser
# The homedir is mandatory.
#
function create_hadoop_user {
	local user=$1
	local homedir=$2

	if [ \( -z ${user} \) -o \( -z ${homedir} \) ] ; then
		echo "Username and/or home directory cannot be empty. Skipping..."
		return;
	fi
	
	echo "Create user ${user}"
	sudo useradd -G ${HADOOP_GROUP} ${user}
	echo "Create hdfs user home dir"
	sudo mkdir -p ${homedir}
	echo "Copy skeleton files from /etc/skel"
	sudo cp -r /etc/skel/. ${homedir}
	echo "Setup permissions and keys"
	sudo chmod -R 700 ${homedir}
	sudo chown -R ${user}:${HADOOP_GROUP} ${homedir}

#	cat << EOF | sudo -u ${user} ssh-keygen
#
#
#
#	EOF
#	sudo -u ${user} sh -c "cat ${homedir}/.ssh/id_rsa.pub >> ${homedir}/.ssh/authorized_keys"

	sudo -u ${user} ssh-keygen
    sudo -u ${user} sh -c "cat ${homedir}/.ssh/id_rsa.pub >> ${homedir}/.ssh/authorized_keys"
}

# Function setup_dirs
#
# Sets up the directories of the hadoop cluster.
function setup_hadoop_dirs {
    echo "Create namenode dir"
    create_owned_dir ${DFS_NAME_DIR} ${HDFS_USER} ${HADOOP_GROUP}
    sudo chmod -R 755 ${DFS_NAME_DIR}
    echo "Create datanode dir"
    create_owned_dir ${DFS_DATA_DIR} ${HDFS_USER} ${HADOOP_GROUP}
    sudo chmod -R 755 ${DFS_DATA_DIR}
    echo "Create hdfs log dir"
    create_owned_dir ${HDFS_LOG_DIR} ${HDFS_USER} ${HADOOP_GROUP}
    sudo chmod -R 755 ${HDFS_LOG_DIR}
    echo "Create hdfs pid dir"
    create_owned_dir ${HDFS_PID_DIR} ${HDFS_USER} ${HADOOP_GROUP}
    sudo chmod -R 777 ${HDFS_PID_DIR}
    echo "Create yarn local dir"
    create_owned_dir ${YARN_LOCAL_DIR} ${YARN_USER} ${HADOOP_GROUP}
    sudo chmod -R 755 ${YARN_LOCAL_DIR}
    echo "Create yarn local log dir"
    create_owned_dir ${YARN_LOCAL_LOG_DIR} ${YARN_USER} ${HADOOP_GROUP}
    sudo chmod -R 755 ${YARN_LOCAL_LOG_DIR}
    echo "Create yarn log dir"
    create_owned_dir ${YARN_LOG_DIR} ${YARN_USER} ${HADOOP_GROUP}
    sudo chmod -R 755 ${YARN_LOG_DIR}
    echo "Create yarn pid dir"
    create_owned_dir ${YARN_PID_DIR} ${YARN_USER} ${HADOOP_GROUP}
    sudo chmod -R 777 ${YARN_PID_DIR}
    echo "Create mapreduce log dir"
    create_owned_dir ${MAPRED_LOG_DIR} ${MAPRED_USER} ${HADOOP_GROUP}
    sudo chmod -R 755 ${MAPRED_LOG_DIR}
    echo "Create mapreduce pid dir"
    create_owned_dir ${MAPRED_PID_DIR} ${MAPRED_USER} ${HADOOP_GROUP}
    sudo chmod -R 777 ${MAPRED_PID_DIR}
}

# Function create_owned_dir
#
# Sets up a directory if it does not exist and sets up proper user rights.
# Receives 4 parameters. The first one is the priority to create.
# The second one is the user owner.
# The third one is the group owner.
function create_owned_dir {
    local DIR_TO_CREATE=$1
    local USER=$2
    local GROUP=$3
	if [ \( -z ${DIR_TO_CREATE} \) -o \( -z ${USER} \) -o \( -z ${GROUP} \) ] ; then
		echo "Directory to create or user or group variables are empty. Skipping..."
		return;
	fi

	echo "Creating direcotyr ${DIR_TO_CREATE}"
	sudo mkdir -p ${DIR_TO_CREATE}
	sudo chown -R ${USER}:${GROUP} ${DIR_TO_CREATE}
}

# Installs hadoop to the /opt/hadoop directory.
# Home directory is /opt/hadoop regardless of version.
function install_hadoop {
  # @todo: Check if homedir already exists.
  if [[ -d ${HADOOP_HOME} ]] ; then
    sudo mkdir -p ${HADOOP_HOME}
  fi
  cd ${HADOOP_HOME}
  sudo curl http://ftp.tc.edu.tw/pub/Apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | sudo tar xz
  sudo mv ./hadoop-${HADOOP_VERSION}/* .
  sudo mv ./hadoop-${HADOOP_VERSION}/.* .
  sudo rmdir ./hadoop-${HADOOP_VERSION}
  sudo chown -R ${HDFS_USER} /opt/hadoop
}


# Sets up environemnt variables and placed them to the
# /etc/profile.d directory so that all new users can
# use them.
function setup_hadoop_profile {
  local file=/etc/profile.d/hadoop-init.sh
  local tempfile=/tmp/hadoop_setup_sdfds.sh
  sudo mkdir -p /tmp/hadoop
  sudo chown ${HDFS_USER} -R /tmp/hadoop
  cat >> ${tempfile}  <<EOT
export HADOOP_HOME=${HADOOP_HOME}
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOT
  chmod +x ${tempfile}
  sudo chown root ${tempfile}
  sudo mv ${tempfile} ${file}
  sudo rm ${tempfile}
}
