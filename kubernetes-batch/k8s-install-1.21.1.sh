#!/bin/bash 


# Step1: ---------------------------------------------------------------------------------------------------------------------------------
Create Security Group and all all Traffic port as of now on temprory bases. Use this Security Group while launching Maseter and Worker ec2.

#Step2: ---------------------------------------------------------------------------------------------------------------------------------
##### Launche ec2 instances
###### Use your Security Group while luanching and your keypair
# 1) ec2 master Node Configuration - instance name : Ubuntu - Ubuntu, 22.04 LTS  - t2.medium - create key pair -network setting , security group set to allow all traffic as of now from anywhere  --> launch instace
# 2) ec2 Worker Node Configuration - instance name : Ubuntu - Ubuntu, 22.04 LTS  - t2.micro - use existing key pair for master -network setting  , use existing security group for master - instance number 2 --> launch instace


#

# Step3: ---------------------------------------------------------------------------------------------------------------------------------
##### Putty(ssh) Master and Worker ec2 and perofrm below commands on both - Login with root user #####
sudo su -

apt-get update -y
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common  -y
apt-get install docker.io -y
wget -q -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo deb http://apt.kubernetes.io/ kubernetes-xenial main | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install kubelet=1.21.1-00 kubeadm=1.21.1-00 kubectl=1.21.1-00 -y
sudo apt-mark hold kubelet kubeadm kubectl
sysctl net.bridge.bridge-nf-call-iptables=1


# Step4: # On master Side ---------------------------------------------------------------------------------------------------------------------------------
sudo su -

kubeadm init --pod-network-cidr=192.168.0.0/16 >> cluster_initialized.txt
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
#kubectl apply -f https://docs.projectcalico.org/archive/v3.20/manifests/calico.yaml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml -O
kubectl apply -f calico.yaml

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

sudo echo 'Environment="cgroup-driver=systemd/cgroup-driver=cgroupfs"' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
systemctl restart kubelet.service

## create token to join workernode. execute below commands output on worker side.
kubeadm token create --print-join-command


Step5: ---------------------------------------------------------------------------------------------------------------------------------
#On Worker Side
## Execute 'kubeadm token' command output from master node and run it in Worker node. So that it will join to as a Worker node in k8s cluster
For example: ##kubeadm join 172.31.22.254:6443 --token t5wam7.35gqolngm80zf9di --discovery-token-ca-cert-hash sha256:60b88e1203525836853e98022aefe92348262bf8e63986dece6bb8270209daf4

Step6: ---------------------------------------------------------------------------------------------------------------------------------
# On Master Side, now execute below command to check cluster nodes.
kubectl get nodes
kubectl -n kube-system rollout restart deploy coredns
systemctl restart kubelet.service
