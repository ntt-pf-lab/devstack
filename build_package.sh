VERSION=$1
DEST=`pwd`/package_$VERSION
DIST='natty'
NOVA_DIR=$DEST/nova
GLANCE_DIR=$DEST/glance
KEYSTONE_DIR=$DEST/keystone
NOVACLIENT_DIR=$DEST/python-novaclient
OPENSTACKX_DIR=$DEST/openstackx
NOVNC_DIR=$DEST/noVNC
SWIFT_DIR=$DEST/swift
SWIFT_KEYSTONE_DIR=$DEST/swift-keystone2
QUANTUM_DIR=$DEST/quantum

export DEB_BUILD_OPTIONS=nodocs

#We can use same file on stackrc
source ./stackrc

if [ $# -ne 1 ]; then
  echo "usage:  ./build_package VERSION"
  exit
fi

if [ -d $DEST ];then
  echo "[WARNING] $DEST is already exsist. Please check it"
fi;
mkdir $DEST

sudo add-apt-repository ppa:nova-core/trunk -y
sudo apt-get update
sudo apt-get install -y build-dep nova
sudo apt-get install python-swift dpkg-dev quilt debhelper  python-ldap python-memcache python-nova python-webtest python-passlib python-coverage python-mock

#Retrive packaging branch
bzr branch lp:~openstack-ubuntu-packagers/nova/diablo $DEST/nova-packaging
bzr branch lp:~ntt-pf-lab/glance/diablo $DEST/glance-packaging
bzr branch lp:~ntt-pf-lab/keystone/ubuntu $DEST/keystone-packaging
bzr branch lp:~openstack-ubuntu-packagers/python-novaclient/diablo $DEST/python-novaclient-packaging

# git clone only if directory doesn't exist already.  Since ``DEST`` might not
# be owned by the installation user, we create the directory and change the
# ownership to the proper user.
function git_clone {

    GIT_REMOTE=$1
    GIT_DEST=$2
    GIT_BRANCH=$3

    # do a full clone only if the directory doesn't exist
    if [ ! -d $GIT_DEST ]; then
        git clone $GIT_REMOTE $GIT_DEST
        cd $2
        # This checkout syntax works for both branches and tags
        git checkout $GIT_BRANCH
    elif [[ "$RECLONE" == "yes" ]]; then
        # if it does exist then simulate what clone does if asked to RECLONE
        cd $GIT_DEST
        # set the url to pull from and fetch
        git remote set-url origin $GIT_REMOTE
        git fetch origin
        # remove the existing ignored files (like pyc) as they cause breakage
        # (due to the py files having older timestamps than our pyc, so python
        # thinks the pyc files are correct using them)
        find $GIT_DEST -name '*.pyc' -delete
        git checkout -f origin/$GIT_BRANCH
        # a local branch might not exist
        git branch -D $GIT_BRANCH || true
        git checkout -b $GIT_BRANCH
      fi
}

function build_package {
    PACKAGE_BRANCH=$1
    BRANCH=$2
    cp -r $PACKAGE_BRANCH/debian $BRANCH
    cd $BRANCH
    dch -b -v $VERSION -D $DIST "$VERSION build"
    QUILT_PATCHES=debian/patches quilt push -a
    if [ -e ./builddeb.sh ];then
      ./builddeb.sh
    else
      dpkg-buildpackage -b -rfakeroot -tc -uc -D
    fi
}

# compute service
git_clone $NOVA_REPO $NOVA_DIR $NOVA_BRANCH
# storage service
git_clone $SWIFT_REPO $SWIFT_DIR $SWIFT_BRANCH
# swift + keystone middleware
git_clone $SWIFT_KEYSTONE_REPO $SWIFT_KEYSTONE_DIR $SWIFT_KEYSTONE_BRANCH
# image catalog service
git_clone $GLANCE_REPO $GLANCE_DIR $GLANCE_BRANCH
# unified auth system (manages accounts/tokens)
git_clone $KEYSTONE_REPO $KEYSTONE_DIR $KEYSTONE_BRANCH
# a websockets/html5 or flash powered VNC console for vm instances
git_clone $NOVNC_REPO $NOVNC_DIR $NOVNC_BRANCH
# django powered web control panel for openstack
git_clone $HORIZON_REPO $HORIZON_DIR $HORIZON_BRANCH $HORIZON_TAG
# python client library to nova that horizon (and others) use
git_clone $NOVACLIENT_REPO $NOVACLIENT_DIR $NOVACLIENT_BRANCH
# openstackx is a collection of extensions to openstack.compute & nova
# that is *deprecated*.  The code is being moved into python-novaclient & nova.
git_clone $OPENSTACKX_REPO $OPENSTACKX_DIR $OPENSTACKX_BRANCH
# quantum
git_clone $QUANTUM_REPO $QUANTUM_DIR $QUANTUM_BRANCH

build_package $DEST/nova-packaging $NOVA_DIR
build_package $DEST/glance-packaging $GLANCE_DIR
build_package $DEST/keystone-packaging $KEYSTONE_DIR
build_package $DEST/python-novaclient-packaging $NOVACLIENT_DIR
