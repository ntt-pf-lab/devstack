#!/bin/sh -e
# Demo config module. This is more a regression/stress test than anything.

# Note this stanza is only here to make this script work in an uninstalled
# debconf source tree, and is not needed in production code.
PATH=$PATH:.
if [ -e confmodule ]; then
        . confmodule
else
        . /usr/share/debconf/confmodule
fi

db_version 2.0
#db_capb backup
db_capb escape
db_settitle openstack/title

# This implements a simple state machine so the back button can be handled.
STATE=1
while [ "$STATE" != 0 -a "$STATE" != 10 ]; do
        case $STATE in
        1)
                db_input high openstack/node_type || true
        ;;
        2)
                db_input high openstack/service_type || true
        ;;
        3)
                db_input critical openstack/service_password || true
                db_input critical openstack/admin_password || true
        ;;
        4)
                db_beginblock
                db_input high openstack/mysql_host || true
                db_input high openstack/mysql_user || true
                db_input high openstack/mysql_password || true
                db_endblock
        ;;
        5)
                db_beginblock
                db_input high openstack/rabbit_host || true
                db_input high openstack/rabbit_user || true
                db_input high openstack/rabbit_password || true
                db_endblock
        ;;
        6)
                 db_input high openstack/virt_driver || true
                 db_input high openstack/net_man || true
                 db_input high openstack/fixed_ragne || true
                 db_input high openstack/floating_range  || true
        ;;
        7)
                db_input high  openstack/setup_database || true
        ;;
        esac
        if db_go; then
                STATE=$(($STATE + 1))
        else
                STATE=$(($STATE - 1))
        fi
#       echo "ON STATE: $STATE"
done

db_stop
