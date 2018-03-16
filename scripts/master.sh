#!/usr/bin/env bash

VAGRANT_USER="vagrant"
VAGRANT_KEY="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant"

wget $VAGRANT_KEY -O /home/$VAGRANT_USER/.ssh/id_rsa
chown $VAGRANT_USER:$VAGRANT_USER /home/$VAGRANT_USER/.ssh/id_rsa
chmod 0600 /home/$VAGRANT_USER/.ssh/id_rsa