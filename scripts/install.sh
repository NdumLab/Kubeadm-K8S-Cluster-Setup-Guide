#!/bin/bash

echo "Step 1: Update packages and Add iptables"
sudo apt-get update -y
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter 
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo "TASK 2: Verify br_netfilter, overlay modules are loaded"
lsmod | grep br_netfilter
lsmod | grep overlay


echo "TASK 3: Update Packages and cert., curl and gnupg Utilities"
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg -y


echo "TASK 4: Verify iptables are set to 1"
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

echo "TASK 5: Disable and turn off SWAP"
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a


echo "TASK 6: Add Docker’s official GPG key"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg


echo "TASK 7: Set up Runtime repository"
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


echo "TASK 8: Update the apt packages and Install containerd"
sudo apt-get update -y
sudo apt-get install containerd.io -y

sudo cat <<EOF | sudo tee /etc/containerd/config.toml
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
       SystemdCgroup = true
EOF

sudo systemctl enable containerd
sudo systemctl restart containerd

echo "TASK 10: Download the Google Cloud public signing key"
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "[ TASK 3] Add Kubernetes apt repo"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "TASK 11:  Installing kubeadm`, Kubelet, and kubectl"
sudo apt-get update -y
sudo apt -y install kubelet=1.25.3-00 kubeadm=1.25.3-00 kubectl=1.25.3-00
sudo apt-mark hold kubelet kubeadm kubectl 


echo "TASK 9: Configure containerd to use Cgroup"

# [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
#   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#     SystemdCgroup = true

# save it and restart `containerd` by running
# sudo systemctl restart containerd


