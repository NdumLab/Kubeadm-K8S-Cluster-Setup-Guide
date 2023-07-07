

**Step 1: Update packages and Add iptables**

```bash
sudo apt-get update -y
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

```

**TASK 2: Verify br_netfilter, overlay modules are loaded**

```bash
lsmod | grep br_netfilter
lsmod | grep overlay

```

**TASK 3: Update Packages and cert., curl and gnupg Utilities**

```bash
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg -y
```

**TASK 4: Verify iptables are set to 1**

```bash
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```
**TASK 5: Disable and turn off SWAP"**

```bash
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a
```

**TASK 6: Add Docker’s official GPG key"**

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

**TASK 7: Set up Runtime repository**

```bash
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**TASK 8: Update the apt packages and Install containerd**

```bash
sudo apt-get update -y
sudo apt-get install containerd.io -y
sudo systemctl enable containerd
sudo systemctl restart containerd
```
**TASK 9: Configure containerd to use `Cgroup**
- Use your favorite file editor to open `config.toml` file.

```bash
sudo vi /etc/containerd/config.toml
```
- Add below config to `config.toml` file.

```bash
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```
save it and restart `containerd` by running

```bash
sudo systemctl restart containerd
```

**TASK 10: Download the Google Cloud public signing key**

```bash
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "[ TASK 3] Add Kubernetes apt repo"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
**TASK 11:  Installing `kubeadm`, `Kubelete`, and `kubectl**
sudo apt-get update -y
sudo apt -y install kubelet=1.25.3-00 kubeadm=1.25.3-00 kubectl=1.25.3-00
sudo apt-mark hold kubelet kubeadm kubectl 


**TASK 12 Bootsrap Kubernetes Cluster**

- To initialize a cluster, run

```bash
sudo kubeadm init --apiserver-advertise-address=$IP
```
Wait till initialization process is completed on the `control-plane` or `master` node.

- Once completed, run the following to set and make `kubeconfig` file executable

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Add Worker nodes to the Cluster 

### Deploy Container Network Interface(**CNI**)

kubectl patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

