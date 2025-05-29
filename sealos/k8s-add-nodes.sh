#!/usr/bin/env bash

# shellcheck disable=SC2154

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
echo "Current Directory: $CD"

source "$CD"/config.sh

read -r -p "Please input password of the nodes to add[123456]: " passwd
passwd=${passwd:-123456}
read -r -p "Please input type of the nodes to add(nodes|masters)[nodes]: " node_type
node_type=${node_type:-nodes}
read -r -p "Please input ip addresses of the nodes to add[127.0.0.1]: " add_nodes
add_nodes=${add_nodes:-127.0.0.1}

for node in $(echo "$add_nodes" | tr "," "\n")
do
    echo "config for node $node"
    sshpass -p "$passwd" ssh -p "$port" "root@$node" -o StrictHostKeyChecking=no 'bash -s' < "$CD"/pre_init.sh 2>/dev/null
done

# add nodes or masters
sealos add --"$node_type" "$add_nodes" --port "$port" --passwd "$passwd"

# post init after add nodes for k8s
for node in $(echo "$add_nodes" | tr "," "\n")
do
    echo "post init for node $node"
    sshpass -p "$passwd" ssh -p "$port" "root@$node" -o StrictHostKeyChecking=no 'bash -s' < "$CD"/post_init.sh 2>/dev/null
done
