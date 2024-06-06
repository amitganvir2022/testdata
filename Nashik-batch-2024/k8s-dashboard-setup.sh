#### ------ Master side only ------------
## Deploy k8s dashboard on Cluster
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

## Crating Service account and giving Full Cluster access.
cat <<EOF | sudo tee dashboard.rb
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f dashboard.rb

## Replace ClusterIP to NodePort for servcie account
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'

##Check your External PortNumber <NodePort>. Using Below URL
kubectl -n kubernetes-dashboard get svc

## Create a Admin-token the admin-user account and Login with Token for the below URL
kubectl create token admin-user -n kubernetes-dashboard

## Verify Dashobard On firefox/chrome with HTTPS and Login with Above Admin-token
https://<ec2--Public-ip>:<NodePort>

