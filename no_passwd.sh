#!/bin/bash

#ssh-keygen


nodes=$(cat add_ssd_nodes.config)

for remote in $nodes; do
    i=${remote#*@}
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $i

#    scp install_docker ${remote}:~/
    ssh -t ${remote} "docker --version;docker ps"
done



