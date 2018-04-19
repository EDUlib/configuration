#!/bin/bash
##
## Installs the pre-requisites for running edX on a single Ubuntu 16.04
## instance.  This script is provided as a convenience and any of these
## steps could be executed manually.
##
## Note that this script requires that you have the ability to run
## commands as root via sudo.  Caveat Emptor!
##

##
## Sanity check
##
if [[ `lsb_release -rs` != "16.04" ]]; then
   echo "This script is only known to work on Ubuntu 16.04, exiting...";
   exit;
fi

##
## Set ppa repository source for gcc/g++ 4.8 in order to install insights properly
##
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

##
## Update and Upgrade apt packages
##
sudo apt-get update -y
sudo apt-get upgrade -y

##
## Install system pre-requisites
##
sudo apt-get install -y build-essential software-properties-common curl git-core libxml2-dev libxslt1-dev python-pip libmysqlclient-dev python-apt python-dev libxmlsec1-dev libfreetype6-dev swig gcc g++
sudo pip install --upgrade pip==9.0.3
sudo pip install --upgrade setuptools==39.0.1
sudo -H pip install --upgrade virtualenv==15.2.0

##### AJOUT PAR EDULIB 20170720
CONFIGURATION_VERSION="edulib-ginkgo.1rc1"
OPENEDX_RELEASE="edulib-ginkgo.1rc1"
##### AJOUT PAR EDULIB 2017072o


##
## Overridable version variables in the playbooks. Each can be overridden
## individually, or with $OPENEDX_RELEASE.
##
### EDULIB NOT INSTALLING PROGRAMS_VERSION
VERSION_VARS=(
  edx_platform_version
  certs_version
  forum_version
  xqueue_version
  configuration_version
  demo_version
  NOTIFIER_VERSION
  INSIGHTS_VERSION
  ANALYTICS_API_VERSION
  ECOMMERCE_VERSION
  ECOMMERCE_WORKER_VERSION
  DISCOVERY_VERSION
)

for var in ${VERSION_VARS[@]}; do
  # Each variable can be overridden by a similarly-named environment variable,
  # or OPENEDX_RELEASE, if provided.
  ENV_VAR=$(echo $var | tr '[:lower:]' '[:upper:]')
  eval override=\${$ENV_VAR-\$OPENEDX_RELEASE}
  if [ -n "$override" ]; then
    EXTRA_VARS="-e $var=$override $EXTRA_VARS"
  fi
done
#####EXTRA_VARS="-e SANDBOX_ENABLE_ECOMMERCE=True $EXTRA_VARS"
#####for var in ${VERSION_VARS[@]}; do
#####  # Each variable can be overridden by a similarly-named environment variable,
#####  # or OPENEDX_RELEASE, if provided.
#####  ENV_VAR=$(echo $var | tr '[:lower:]' '[:upper:]')
#####  eval override=\${$ENV_VAR-\$OPENEDX_RELEASE}
#####  if [ -n "$override" ]; then
#####    EXTRA_VARS="-e $var=$override $EXTRA_VARS"
#####  fi
#####done

# my-passwords.yml is the file made by generate-passwords.sh.
if [[ -f my-passwords.yml ]]; then
    EXTRA_VARS="-e@$(pwd)/my-passwords.yml $EXTRA_VARS"
fi

INTER_RELEASE="edulib-release-2017-06-21-12.22"

if [ -n "$OPENEDX_RELEASE" ]; then
  EXTRA_VARS="-e edx_platform_version=$INTER_RELEASE \
    -e certs_version=$OPENEDX_RELEASE \
    -e forum_version=$OPENEDX_RELEASE \
    -e xqueue_version=$OPENEDX_RELEASE \
    -e configuration_version=$OPENEDX_RELEASE \
    -e demo_version=$OPENEDX_RELEASE \
    -e NOTIFIER_VERSION=$OPENEDX_RELEASE \
    -e INSIGHTS_VERSION=$OPENEDX_RELEASE \
    -e ANALYTICS_API_VERSION=$OPENEDX_RELEASE \
  $EXTRA_VARS"
fi

#if [ -n "$OPENEDX_RELEASE" ]; then
#  EXTRA_VARS="-e edx_platform_version=$OPENEDX_RELEASE \
#    -e certs_version=$OPENEDX_RELEASE \
#    -e forum_version=$OPENEDX_RELEASE \
#    -e xqueue_version=$OPENEDX_RELEASE \
#    -e configuration_version=$OPENEDX_RELEASE \
#    -e demo_version=$OPENEDX_RELEASE \
#    -e NOTIFIER_VERSION=$OPENEDX_RELEASE \
#    -e INSIGHTS_VERSION=$OPENEDX_RELEASE \
#    -e ANALYTICS_API_VERSION=$OPENEDX_RELEASE \
#  $EXTRA_VARS"
#fi

##
## Clone the configuration repository and run Ansible
##
cd /var/tmp
git clone https://github.com/EDUlib/configuration
cd configuration
git checkout $CONFIGURATION_VERSION
git pull

##
## Install the ansible requirements
##
cd /var/tmp/configuration
sudo -H pip install -r requirements.txt

##
## Run the edx_sandbox.yml playbook in the configuration/playbooks directory
##
cd /var/tmp/configuration/playbooks && sudo -E ansible-playbook -v -c local ./edx_sandbox.yml -i "localhost," $EXTRA_VARS "$@"
