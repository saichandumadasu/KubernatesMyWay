# Get the kube-scheduler logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath="{.items[0].metadata.name}")

# Describe the kube-scheduler pod
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath="{.items[0].metadata.name}")

# Get the kube-scheduler configuration
kubectl get configmap -n kube-system kube-scheduler -o yaml

# Edit the kube-scheduler configuration
kubectl edit configmap -n kube-system kube-scheduler

# Get the kube-scheduler deployment (if running as a deployment)
kubectl get deployment -n kube-system kube-scheduler

# Describe the kube-scheduler deployment (if running as a deployment)
kubectl describe deployment -n kube-system kube-scheduler

# Get the kube-scheduler service (if running as a service)
kubectl get svc -n kube-system kube-scheduler

# Describe the kube-scheduler service (if running as a service)
kubectl describe svc -n kube-system kube-scheduler

# Get the kube-scheduler endpoints (if running as a service)
kubectl get endpoints -n kube-system kube-scheduler

# Describe the kube-scheduler endpoints (if running as a service)
kubectl describe endpoints -n kube-system kube-scheduler

# Get the kube-scheduler pod logs with a specific container
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath="{.items[0].metadata.name}") -c kube-scheduler

# Port forward to the kube-scheduler pod
kubectl port-forward -n kube-system $(kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath="{.items[0].metadata.name}") <local-port>:<pod-port>
