#!/bin/bash
set -x
# Keep track of the current directory
PACKAGE_DIR=$(cd $(dirname "$0") && pwd)
PACKAGE_NAME='openstack-installer_0.0.1'
TOP_DIR=`cd $PACKAGE_DIR/..; pwd`

rm -rf $PACKAGE_DIR/$PACKAGE_NAME/opt/stack/devstack
mkdir -p $PACKAGE_DIR/$PACKAGE_NAME/opt/stack/devstack
(cd $TOP_DIR; find . -type d | grep -v $PACKAGE_NAME | xargs -I% mkdir -p $PACKAGE_DIR/$PACKAGE_NAME/opt/stack/devstack/%)
(cd $TOP_DIR; find . -type f | grep -v $PACKAGE_NAME | xargs -I% cp % $PACKAGE_DIR/$PACKAGE_NAME/opt/stack/devstack/%)
dpkg --build openstack-installer_0.0.1

