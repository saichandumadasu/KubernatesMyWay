# Get all etcd pods in the kube-system namespace
kubectl get pods -n kube-system -l component=etcd

# Describe the etcd pod
kubectl describe pod <etcd-pod-name> -n kube-system

# Get logs from the etcd pod
kubectl logs <etcd-pod-name> -n kube-system

# Execute a command inside the etcd pod
kubectl exec -it <etcd-pod-name> -n kube-system -- /bin/sh

# Get the etcd service
kubectl get svc -n kube-system -l component=etcd

# Describe the etcd service
kubectl describe svc <etcd-service-name> -n kube-system

# Get the etcd endpoints
kubectl get endpoints -n kube-system -l component=etcd

# Describe the etcd endpoints
kubectl describe endpoints <etcd-endpoints-name> -n kube-system

# Get the etcd configmap
kubectl get configmap -n kube-system -l component=etcd

# Describe the etcd configmap
kubectl describe configmap <etcd-configmap-name> -n kube-system

# Get the etcd secrets (e.g., certificates)
kubectl get secrets -n kube-system -l component=etcd

# Describe the etcd secrets
kubectl describe secret <etcd-secret-name> -n kube-system

# Update etcd certificates (example for a secret)
kubectl create secret generic <etcd-secret-name> --from-file=<path-to-cert-file> -n kube-system --dry-run=client -o yaml | kubectl apply -f -

# Scale the etcd deployment (if applicable)
kubectl scale deployment <etcd-deployment-name> --replicas=<number-of-replicas> -n kube-system

# Get the etcd deployment (if applicable)
kubectl get deployment -n kube-system -l component=etcd

# Describe the etcd deployment (if applicable)
kubectl describe deployment <etcd-deployment-name> -n kube-system