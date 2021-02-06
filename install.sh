#!/bin/bash
#getting some environment vars
source /etc/lsb-release

sudo apt update > /dev/null 2>&1
sudo apt install software-properties-common -y
sudo apt-add-repository universe > /dev/null 2>&1
sudo apt-add-repository multiverse > /dev/null 2>&1
if [ "$DISTRIB_CODENAME" = "bionic" ]
then
    sudo apt-add-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1
fi
sudo apt update > /dev/null 2>&1
sudo apt install nano git ansible -y

cp vars.yml.example vars.yml
cp inventory.example inventory

function generatePassword() {
    openssl rand -hex 16
}

NCADMIN=$(generatePassword)

sed -i \
    -e "s#ncadminpw:.*#ncadminpw: ${NCADMIN}#g" \
    "$(dirname "$0")/vars.yml"