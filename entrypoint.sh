#!/bin/bash

# Spark likes to be able to lookup a username for the running UID.
# If no name is present fake it.
myuid=$(id -u)
mygid=$(id -g)
uidentry=$(getent passwd $myuid)

if [ -z "$uidentry" ] ; then
    # This logic assumes a standard openshift environment, where
    # the uid has no entry, and no group, and so has root-group assigned.
    # Also assumes that /etc/passwd has root-group write privs.
    # It is also possible to add an nss-wrapper fallback that does not
    # require write privs to passwd, however not all linux distros have nss-wrapper.
    echo "$myuid:x:$myuid:$mygid:anonymous uid:$SPARK_HOME:/bin/false" >> /etc/passwd
fi

# Execute the container CMD under tini for better hygiene
/sbin/tini -- $@
