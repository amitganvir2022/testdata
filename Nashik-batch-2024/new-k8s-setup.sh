#!/bin/bash 


# Step1: ---------------------------------------------------------------------------------------------------------------------------------
Create Security Group and allow all Traffic port as of now on temprory bases. Use this Security Group while launching Maseter and Worker ec2.

#Step2: ---------------------------------------------------------------------------------------------------------------------------------
##### Launche ec2 instances
###### Use your Security Group while luanching and your keypair
# 1) ec2 master Node Configuration - instance name : Ubuntu - Ubuntu, 22.04 LTS  - t2.medium - create key pair -network setting , security group set to allow all traffic as of now from anywhere  --> launch instace
# 2) ec2 Worker Node Configuration - instance name : Ubuntu - Ubuntu, 22.04 LTS  - t2.micro - use existing key pair for master -network setting  , use existing security group for master - instance number 2 --> launch instace


# Step3: ---------------------------------------------------------------------------------------------------------------------------------
##### Putty(ssh) Master and Worker ec2 and perofrm below commands on both - Login with root user #####
sudo su -

sudo apt update
apt-get install docker.io -y
#sudo apt install apt-transport-https ca-certificates curl software-properties-common  -y
sudo systemctl enable docker

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install kubeadm kubelet kubectl -y
sudo apt-mark hold kubeadm kubelet kubectl
kubeadm version

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"
EOF

cat <<EOF | sudo tee //etc/docker/daemon.json
{
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
      "max-size": "100m"
   },
       "storage-driver": "overlay2"
       }
EOF

echo 'Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' >> /lib/systemd/system/kubelet.service.d/10-kubeadm.conf 
sudo systemctl daemon-reload && sudo systemctl restart docker


# Step4: # On master Side ---------------------------------------------------------------------------------------------------------------------------------
sudo systemctl restart kubelet
sudo kubeadm init --control-plane-endpoint=$(hostname) --pod-network-cidr=10.244.0.0/16 --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl get nodes
kubeadm token create --print-join-command


Step5: ---------------------------------------------------------------------------------------------------------------------------------
#On Worker Side
## Execute 'kubeadm token' command output from master node and run it in Worker node. So that it will join to as a Worker node in k8s cluster
For example: ##kubeadm join 172.31.22.254:6443 --token t5wam7.35gqolngm80zf9di --discovery-token-ca-cert-hash sha256:60b88e1203525836853e98022aefe92348262bf8e63986dece6bb8270209daf4

Step6: ---------------------------------------------------------------------------------------------------------------------------------
# On Master Side, now execute below command to check cluster nodes.
kubectl get nodes
----- DONE ---------

### Run below command if you wnated to test DNS is working or not
## kubectl run busybox --image=busybox:1.28.4 --rm -it --restart=Never --command -- nslookup google.com
## kubectl run busybox --image=busybox --rm -it --restart=Never --command -- nslookup kubernetes.default.svc.cluster.local


