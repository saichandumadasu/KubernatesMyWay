#!/bin/bash

# Start the kube-controller-manager
kube-controller-manager \
    --master=<master-node-ip>:<port> \
    --service-account-private-key-file=<path-to-private-key> \
    --root-ca-file=<path-to-root-ca> \
    --cluster-signing-cert-file=<path-to-signing-cert> \
    --cluster-signing-key-file=<path-to-signing-key> \
    --kubeconfig=<path-to-kubeconfig> \
    --leader-elect=true \
    --controllers=* \
    --allocate-node-cidrs=true \
    --cluster-cidr=<cluster-cidr> \
    --service-cluster-ip-range=<service-cluster-ip-range> \
    --use-service-account-credentials=true \
    --cloud-provider=<cloud-provider> \
    --cloud-config=<path-to-cloud-config> \
    --v=2

# Check the status of the kube-controller-manager
kubectl get componentstatuses kube-controller-manager

# View logs of the kube-controller-manager
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kube-controller-manager -o jsonpath='{.items[0].metadata.name}')

# Restart the kube-controller-manager (if managed by systemd)
sudo systemctl restart kube-controller-manager

# Enable the kube-controller-manager to start on boot (if managed by systemd)
sudo systemctl enable kube-controller-manager

# Check the kube-controller-manager service status (if managed by systemd)
sudo systemctl status kube-controller-manager

# List all controllers managed by kube-controller-manager
kubectl get deployments --all-namespaces
kubectl get replicasets --all-namespaces
kubectl get statefulsets --all-namespaces
kubectl get daemonsets --all-namespaces
kubectl get jobs --all-namespaces
kubectl get cronjobs --all-namespaces

# Scale a deployment using kube-controller-manager
kubectl scale deployment <deployment-name> --replicas=<number-of-replicas> -n <namespace>

# Manually trigger a rollout of a deployment
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Check the rollout status of a deployment
kubectl rollout status deployment <deployment-name> -n <namespace>

# Pause a deployment
kubectl rollout pause deployment <deployment-name> -n <namespace>

# Resume a paused deployment
kubectl rollout resume deployment <deployment-name> -n <namespace>

# Undo a deployment rollout
kubectl rollout undo deployment <deployment-name> -n <namespace>

# Get the history of a deployment
kubectl rollout history deployment <deployment-name> -n <namespace>

# Describe a deployment
kubectl describe deployment <deployment-name> -n <namespace>

# Delete a deployment
kubectl delete deployment <deployment-name> -n <namespace>

# Create a new deployment
kubectl create deployment <deployment-name> --image=<image-name> -n <namespace>

# Update the image of a deployment
kubectl set image deployment/<deployment-name> <container-name>=<new-image> -n <namespace>

# Get the configuration of the kube-controller-manager
kubectl -n kube-system get configmap kube-controller-manager -o yaml

# Edit the configuration of the kube-controller-manager
kubectl -n kube-system edit configmap kube-controller-manager

# Apply changes to the kube-controller-manager configuration
kubectl apply -f <path-to-config-file> -n kube-system

# Delete the kube-controller-manager pod to apply new configuration (it will be recreated automatically)
kubectl delete pod -n kube-system -l component=kube-controller-manager