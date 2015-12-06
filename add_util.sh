#!/bin/bash


set -e


nodes_add=$(cat add_node.config)





function prepare-add() {

    source "${KUBE_ROOT}/cluster/ubuntu/util.sh"
    source "${KUBE_ROOT}/cluster/ubuntu/config-default.sh"

    setClusterInfo

}

function add-nodes(){
    for i in $nodes_add; do
        echo "the node to be added is $i"
        echo

        add-node $i


    done


}


function add-node() {
    # add node to current cluster
    echo "adding node on cluster with master ${MASTER_IP} " 
    echo "add new node on machine ${1#*@}"
    echo
    ssh $SSH_OPTS $1 "mkdir -p ~/kube/default"
    

    echo "make dir complete"
    scp -r $SSH_OPTS ${KUBE_ROOT}/cluster/ubuntu/config-default.sh ${KUBE_ROOT}/cluster/ubuntu/util.sh ${KUBE_ROOT}/cluster/ubuntu/reconfDocker.sh ${KUBE_ROOT}/cluster/ubuntu/minion/* ${KUBE_ROOT}/cluster/ubuntu/binaries/minion "${1}:~/kube"

    echo "copy completing"

  # remote login to MASTER and use sudo to configue k8s master
    ssh $SSH_OPTS -t $1 "source ~/kube/util.sh; \
                         setClusterInfo; \
                         create-kubelet-opts "${1#*@}" "${MASTER_IP}" "${DNS_SERVER_IP}" "${DNS_DOMAIN}"; \
                         create-kube-proxy-opts "${MASTER_IP}"; \
                         create-flanneld-opts "${MASTER_IP}"; \
                         sudo -p '[sudo] password to start node: ' cp ~/kube/default/* /etc/default/ && sudo cp ~/kube/init_conf/* /etc/init/ && sudo cp ~/kube/init_scripts/* /etc/init.d/ \
                         && sudo mkdir -p /opt/bin/ && sudo cp ~/kube/minion/* /opt/bin; \
                         sudo service flanneld start; \
                         sudo -b ~/kube/reconfDocker.sh "i";"
}

function remove-node() {
    

    ssh -t $i 'pgrep flanneld && sudo -p "[sudo] password to stop node: " service flanneld stop'
      # Delete the files in order to generate a clean environment, so you can change each node's role at next deployment.
      ssh -t $i 'sudo rm -f /opt/bin/kube* /opt/bin/flanneld;
      sudo rm -rf /etc/init/kube* /etc/init/flanneld.conf /etc/init.d/kube* /etc/init.d/flanneld;
      sudo rm -rf /etc/default/kube* /etc/default/flanneld; 
      sudo rm -rf ~/kube /var/lib/kubelet;
      sudo rm -rf /run/flannel/subnet.env' || true
    

}






