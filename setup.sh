#!/bin/bash

source bootstrap.sh

cmd_ask_to_confirm "Update Repository? [y/N] " && update_apt_repo
cmd_ask_to_confirm "Install Java? [y/N] " && install_java
cmd_ask_to_confirm "Setup hadoop users? [y/N] " && setup_hadoop_users
cmd_ask_to_confirm "Setup hadoop directories? [y/N] " && setup_hadoop_dirs
cmd_ask_to_confirm "Install hadoop? [y/N] " && install_hadoop
cmd_ask_to_confirm "Setup hadoop profile? [y/N] " && setup_hadoop_profile
# @todo: Maybe there will be a need for re-setting ownership to hadoop_home.
