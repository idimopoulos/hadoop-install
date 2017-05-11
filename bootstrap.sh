#!/bin/bash bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/settings.sh
source ${DIR}/bash_common_helpers/bash-common-helpers.sh
source ${DIR}/scripts/hadoop-helpers.sh

BOOTSTRAPPED=1