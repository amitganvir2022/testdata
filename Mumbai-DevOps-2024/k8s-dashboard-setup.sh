## Deploy k8s dashboard on Cluster
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

## Replace ClusterIP to NodePort for servcie account
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'

##Check your External PortNumber <NodePort>.
kubectl -n kubernetes-dashboard get svc

## Giving Cluster access for service account.
kubectl create clusterrolebinding deployment-controller --clusterrole=cluster-admin --serviceaccount=kube-system:deployment-controller
cat <<EOF | sudo tee dashboard.rb
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: deployment-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: deployment-controller
  namespace: kube-system
EOF

kubectl apply -f dashboard.rb

## Get Default Admin-token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | awk '/^deployment-controller-token-/{print $1}') | awk '$1=="token:"{print $2}'

## Verify Dashobard On firefox/chrome and Login with Above Admin-token
https://<ec2-ip>:<NodePort>

