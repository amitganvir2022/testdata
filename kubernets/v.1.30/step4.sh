sudo systemctl restart kubelet
sudo kubeadm init --control-plane-endpoint=$(hostname) --pod-network-cidr=10.244.0.0/16 --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl get nodes

kubeadm token create --print-join-command
