#!/bin/bash

# read from environment
PROJECT=${K8SLC_PROJECT:-${PWD##*/}}
CONTROLLER_CPUS=${K8SLC_CONTROLLER_CPUS:-"2"}
CONTROLLER_RAM=${K8SLC_CONTROLLER_RAM:-"2048"}
WORKER_QUANTITY=${K8SLC_WORKER_QUANTITY:-"3"}
WORKER_CPUS=${K8SLC_WORKER_CPUS:-"2"}
WORKER_RAM=${K8SLC_WORKER_RAM:-"1024"}
K8S_FLAVOUR=${K8SLC_K8S_FLAVOUR:-"xenial"}
K8S_VERSION=${K8SLC_K8S_VERSION:-"1.22.3-00"}
BOX=${K8SLC_BOX:-"generic/ubuntu1804"}
SUBNET=${K8SLC_SUBNET:-"10.224.114.0"}

function showhelp(){
    cat << EOF
Kubernetes laboratory deploy automated tool
Usage:
${0} [options]
Options:
-p, --project           project name.
                        will override value of env K8SLC_PROJECT
                        default: <current-directory-name>
-cc, --controller-cpus  controller node CPU quantity.
                        will override value of env K8SLC_CONTROLLER_CPUS
                        default: 2
-cr, --controller-ram   controller node RAM ammount.
                        will override value of env K8SLC_CONTROLLER_RAM
                        default: 2048
-w,  --workers          worker node quantity.
                        will override value of env K8SLC_WORKER_QUANTITY
                        default: 3
-wc, --worker-cpus      worker node CPU quantity.
                        will override value of env K8SLC_WORKER_CPUS
                        default: 2
-wr, --worker-ram       worker node RAM ammount.
                        will override value of env K8SLC_WORKER_RAM
                        default: 1024
-kd, --k8s-flavour      flavour kubernetes-* to install from 
                        https://packages.cloud.google.com/apt/dists.
                        will override value of env K8SLC_K8S_FLAVOUR
                        Default: xenial
-kv, --k8s-version      version of packages to install
                        will override value of env K8SLC_K8S_VERSION
                        Default: 1.22.3-00
-b,  --box              box of Vagrant to use.
                        will override value of env K8SLC_BOX
                        Default: generic/ubuntu1804
-s, --subnet            IP/24 of the nodes subnet. 
                        will override value of env K8SLC_SUBNET
                        Default: 10.224.114.0
-h,  --help             prints this help message.

More info in:
https://gitlab.com/imanolvalero/lemoncode-devops/tree/main/modulo3-orquestacion/instalacion

EOF
    exit
}

# read from arguments
while [ $# -ne 0 ]
do
    case "$1" in
    -h|--help)
        showhelp
        ;;
    -w|--workers)
        WORKER_QUANTITY="$2"
        shift
        ;;
    -wc|--worker-cpus)
        WORKER_CPUS="$2"
        shift
        ;;
    -wr|--worker-ram)
        WORKER_RAM="$2"
        shift
        ;;
    -cc|--controller-cpus)
        CONTROLLER_CPUS="$2"
        shift
        ;;
    -cr|--controller-ram)
        CONTROLLER_RAM="$2"
        shift
        ;;
    -kd|--k8s-distro)
        CONTROLLER_RAM="$2"
        shift
        ;;
    -kv|--k8s-version)
        WORKER_CPUS="$2"
        shift
        ;;
    -b|--box)
        BOX="$2"
        shift
        ;;
    -s|--subnet)
        SUBNET="$2"
        shift
        ;;
    -p|--project)
        PROJECT="$2"
        shift
        ;;
    *)
        echo "Argument incorrect: $1"
        showhelp
        ;;
    esac
    shift
done

#=========================================================================
# Obtain IP prefix
IFS=. IP_RANGES=(${SUBNET}) IFS=$' \t\n'
IP_PREFIX=${IP_RANGES[0]}.${IP_RANGES[1]}.${IP_RANGES[2]}

# Obtain Kuberbetes version for kubelet config file
KUBELET_VERSION=$(echo ${K8S_VERSION} | sed 's/\(.*\)\-.*/\1/')

# Sanity project name
PROJECT="${PROJECT// /_}"

#=========================================================================
# Vagrantfile
FILE=Vagrantfile
[[ -f ${FILE} ]] && rm ${FILE}
cat <<EOF >> ${FILE}
Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-'SCRIPT'
    apt-get update -y
    apt-get upgrade -y
    apt-get autoremove -y
    apt-get autoclean -y
    echo "${IP_PREFIX}.11 ${PROJECT}-cp1" >> /etc/hosts
EOF

for ((i=1; i<=WORKER_QUANTITY; i++))
do
    echo "    echo \"${IP_PREFIX}.$(( 20 + ${i} )) ${PROJECT}-node${i}\" >> /etc/hosts" >> ${FILE}
done

cat <<EOF >> ${FILE}
    SCRIPT

    config.vm.define "${PROJECT}-cp1" do |controler|
        controler.vm.box = "${BOX}"
        controler.vm.hostname = "${PROJECT}-cp1"
        controler.vm.network "private_network", ip: "${IP_PREFIX}.11"
        controler.vm.provider "libvirt" do |controlervm|
            controlervm.cpus = ${CONTROLLER_CPUS}
            controlervm.memory = ${CONTROLLER_RAM}
        end
    end
    
    (1..${WORKER_QUANTITY}).each do |machine_id|
        config.vm.define "${PROJECT}-node#{machine_id}" do |node|
            node.vm.box = "${BOX}"
            node.vm.hostname = "${PROJECT}-node#{machine_id}"
            node.vm.network "private_network", ip: "${IP_PREFIX}.#{20+machine_id}"
            node.vm.provider "libvirt" do |nodevm|
                nodevm.cpus = ${WORKER_CPUS}
                nodevm.memory = ${WORKER_RAM}
            end
        end
    end
end
EOF

#=========================================================================
# Inventory.ini
FILE=.inventory.ini
[[ -f ${FILE} ]] && rm ${FILE}

function inventory_line(){
    echo "${1} ansible_host=${2} ansible_ssh_common_args='-i .vagrant/machines/${1}/libvirt/private_key'"
}

cat <<EOF >> ${FILE}
[controller]
$(inventory_line ${PROJECT}-cp1 ${IP_PREFIX}.11)

[workers]
EOF
for ((i=1; i<=WORKER_QUANTITY; i++))
do
    echo $(inventory_line ${PROJECT}-node${i} ${IP_PREFIX}.$(( 20 + ${i} )) ) >> ${FILE}
done

cat <<'EOF' >> ${FILE}
[controller:vars]
ansible_ssh_user='vagrant'
ansible_ssh_common_args='-p 22 -o LogLevel=FATAL -o Compression=yes -o DSAAuthentication=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'


[workers:vars]
ansible_ssh_user='vagrant'
ansible_ssh_common_args='-p 22 -o LogLevel=FATAL -o Compression=yes -o DSAAuthentication=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF

#=========================================================================
# .deploy.json
cat << EOF > .deploy.json
{
    "k8s": {
        "package_version": "${K8S_VERSION}",
        "flavour": "${K8S_FLAVOUR}",
        "version": "${KUBELET_VERSION}",
    },
    "net": {
        "controller": {
            "ip": "${IP_PREFIX}.11"
        }
    },
    "project": {
        "name": "${PROJECT}"
    }
}
EOF
#=========================================================================
# Create vms and deploy k8s
vagrant destroy -f
vagrant up

SCRIPT_NAME=$(basename ${0} | sed 's/\(.*\)\..*/\1/')
ansible-playbook -i ${FILE} ${SCRIPT_NAME}.yaml
