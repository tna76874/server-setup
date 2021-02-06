#!/bin/bash
### getting some environment vars
source /etc/lsb-release

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")

# setting the location of the ansible playbook repository
REPODIR="/root/server-setup"

# exit script if not run by root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

### setting up some functions
function generatePassword() {
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 64
}

function confirm() {
    # call with a prompt string or use a default
    read -r -p "$@"" [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

function prepare_setup() {
    # delete the repository, if present. 
    sudo rm -rf ${REPODIR}

    echo -e "... update system sources, install ansible and git and clone the playbook repository ... [this could take a few minutes now, depending on your internet connection]"
    sudo apt update > /dev/null 2>&1
    sudo apt install software-properties-common -y > /dev/null 2>&1
    sudo apt-add-repository universe > /dev/null 2>&1
    sudo apt-add-repository multiverse > /dev/null 2>&1
    if [ "$DISTRIB_CODENAME" = "bionic" ]
    then
        sudo apt-add-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1
    fi
    sudo apt update > /dev/null 2>&1
    sudo apt install git ansible -y > /dev/null 2>&1

    #clone the playbook repository
    git clone https://github.com/tna76874/server-setup.git ${REPODIR} > /dev/null 2>&1
}

function run_playbook() {
    # run the playbook to set up the system
    cd ${REPODIR}

    cp vars.yml.example vars.yml

    NCADMIN=$(generatePassword)

    read -e -p "Letsencrypt mailadress: " -i "mymail@adress.xyz" LETSENCRYPTMAIL
    read -e -p "Domain: " -i "mydomain.xyz" INSTANCE_DOMAIN
    read -e -p "Hostname: " -i "mhstack" THISHOSTNAME

    echo -e "[all]\n$THISHOSTNAME      ansible_connection=local" > inventory

    sed -i \
        -e "s#ncadminpw:.*#ncadminpw: ${NCADMIN}#g" \
        -e "s#letsencrypt_email:.*#letsencrypt_email: ${LETSENCRYPTMAIL}#g" \
        -e "s#main_domain:.*#main_domain: ${INSTANCE_DOMAIN}#g" \
        "$(dirname "$0")/vars.yml"


    sudo ansible-playbook ${1-main.yml}
}

### Run functions
if $(confirm "Prepare system?") ; then
    sudo prepare_setup
fi

if $(confirm "Set up system?") ; then
    sudo run_playbook
fi

if $(confirm "Install docker?") ; then
    cd ${REPODIR}
    sudo ansible-playbook main.yml -t docker
fi