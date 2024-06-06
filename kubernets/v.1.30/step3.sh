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
