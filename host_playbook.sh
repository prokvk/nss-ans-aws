#!/bin/bash

# Thank you https://nathanleclaire.com/
# https://nathanleclaire.com/blog/2015/11/10/using-ansible-with-docker-machine-to-bootstrap-host-nodes/

if [[ ! -d /hostssh ]]; then
    echo "Must mount the host SSH directory at /hostssh, e.g. 'docker run --net host -v /root/.ssh:/hostssh" && exit 1
fi

# Generate temporary SSH key to allow access to the host machine.
mkdir -p /root/.ssh
[ ! -e /root/.ssh/id_rsa ] && ssh-keygen -f /root/.ssh/id_rsa -P ""

cp /hostssh/authorized_keys /hostssh/authorized_keys.bak
echo -e "\n" >> /hostssh/authorized_keys
cat /root/.ssh/id_rsa.pub >> /hostssh/authorized_keys

RES=$(ssh-keyscan -t rsa localhost)
touch /root/.ssh/known_hosts
echo $RES >> /root/.ssh/known_hosts

ansible-playbook -i "localhost," "$@" -v

mv /hostssh/authorized_keys.bak /hostssh/authorized_keys
