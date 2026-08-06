#!/bin/bash
set -e
echo "=== Nettoyage des namespaces existants (si present) ==="
sudo ip netns del ns1 2>/dev/null || true
sudo ip netns del ns2 2>/dev/null || true
sudo ip link del mybridge 2>/dev/null || true

echo "=== creation des namespaces"
sudo ip netns add ns1
sudo ip netns add ns2

echo "=== creation de la veth pair ==="
sudo ip link add veth1 type veth peer name veth2
sudo ip link set veth1 netns ns1
sudo ip link set veth2 netns ns2

echo "=== Config IP et activation des interfaces"
sudo ip netns exec ns1 ip addr add 10.0.0.1/24 dev veth1
sudo ip netns exec ns2 ip addr add 10.0.0.2/24 dev veth2
sudo ip netns exec ns1 ip link set veth1 up
sudo ip netns exec ns2 ip link set veth2 up
sudo ip netns exec ns1 ip link set lo up
sudo ip netns exec ns2 ip link set lo up

echo "=== Création du bridge ==="
sudo ip link add mybridge type bridge
sudo ip link set mybridge up

echo "=== test de connectivite ==="
sudo ip netns exec ns1 ping -c 3 10.0.0.2

echo "=== lab pret ==="