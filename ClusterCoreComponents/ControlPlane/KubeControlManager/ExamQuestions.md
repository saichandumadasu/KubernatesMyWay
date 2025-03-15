# CKA Exam Scenario-Based Questions

<details>
<summary>## Question 1: Node Failure Recovery</summary>
Your Kubernetes cluster has experienced a node failure. The node `worker-node-1` has gone down unexpectedly. Describe the steps you would take to recover from this failure and ensure that all pods running on `worker-node-1` are rescheduled on other available nodes.

<details>
<summary>Answer</summary>
1. **Identify the failed node**: Use `kubectl get nodes` to confirm the status of `worker-node-1`.
2. **Cordon the node**: Prevent new pods from being scheduled on the failed node using `kubectl cordon worker-node-1`.
3. **Drain the node**: Evict all pods from the node using `kubectl drain worker-node-1 --ignore-daemonsets --delete-local-data`.
4. **Verify pod rescheduling**: Ensure that the pods are rescheduled on other nodes using `kubectl get pods -o wide`.
5. **Investigate and fix the node issue**: Check logs and system status to identify the cause of the failure and fix it.
6. **Uncordon the node**: Once the node is fixed, allow scheduling of new pods using `kubectl uncordon worker-node-1`.

Example:
```bash
kubectl get nodes
kubectl cordon worker-node-1
kubectl drain worker-node-1 --ignore-daemonsets --delete-local-data
kubectl get pods -o wide
# Investigate and fix the node issue
kubectl uncordon worker-node-1
```
</details>
</details>

<details>
<summary>## Question 2: Network Policy Implementation</summary>
You have a namespace `production` with multiple applications running. You need to implement a network policy that allows only the `frontend` pod to communicate with the `backend` pod, and deny all other traffic within the namespace. Explain how you would create and apply this network policy.

<details>
<summary>Answer</summary>
1. **Create a NetworkPolicy YAML file**: Define the policy to allow traffic from `frontend` to `backend`.
2. **Apply the NetworkPolicy**: Use `kubectl apply -f` to apply the policy.

Example NetworkPolicy YAML:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
    name: allow-frontend-to-backend
    namespace: production
spec:
    podSelector:
        matchLabels:
            app: backend
    policyTypes:
    - Ingress
    ingress:
    - from:
        - podSelector:
                matchLabels:
                    app: frontend
```

Apply the policy:
```bash
kubectl apply -f networkpolicy.yaml
```
</details>
</details>

<details>
<summary>## Question 3: Persistent Storage Configuration</summary>
A stateful application in your cluster requires persistent storage. You need to configure a PersistentVolume (PV) and a PersistentVolumeClaim (PVC) to provide storage for the application. Describe the steps to create a PV and PVC, and how to bind them to the application.

<details>
<summary>Answer</summary>
1. **Create a PersistentVolume (PV) YAML file**: Define the storage capacity and access modes.
2. **Create a PersistentVolumeClaim (PVC) YAML file**: Request storage by specifying the storage class and size.
3. **Apply the PV and PVC**: Use `kubectl apply -f` to create the PV and PVC.
4. **Update the application deployment**: Modify the deployment to use the PVC.

Example PV YAML:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
    name: my-pv
spec:
    capacity:
        storage: 10Gi
    accessModes:
        - ReadWriteOnce
    hostPath:
        path: /mnt/data
```

Example PVC YAML:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: my-pvc
spec:
    accessModes:
        - ReadWriteOnce
    resources:
        requests:
            storage: 10Gi
```

Apply the PV and PVC:
```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
```

Update the deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: my-app
spec:
    replicas: 1
    selector:
        matchLabels:
            app: my-app
    template:
        metadata:
            labels:
                app: my-app
        spec:
            containers:
            - name: my-container
                image: my-image
                volumeMounts:
                - mountPath: "/data"
                    name: my-storage
            volumes:
            - name: my-storage
                persistentVolumeClaim:
                    claimName: my-pvc
```
</details>
</details>

<details>
<summary>## Question 4: Cluster Upgrade</summary>
Your Kubernetes cluster is currently running version 1.20, and you need to upgrade it to version 1.21. Outline the steps you would take to perform a safe and successful upgrade of the cluster, including any necessary preparations and post-upgrade checks.

<details>
<summary>Answer</summary>
1. **Backup the cluster**: Ensure you have a backup of all important data and configurations.
2. **Check the upgrade path**: Verify that the upgrade from 1.20 to 1.21 is supported.
3. **Upgrade the control plane components**: Upgrade `kube-apiserver`, `kube-controller-manager`, and `kube-scheduler`.
4. **Upgrade the kubelet and kubectl**: Upgrade the kubelet and kubectl on all nodes.
5. **Verify the upgrade**: Check the status of the cluster and ensure all components are running the new version.
6. **Run post-upgrade tests**: Validate the functionality of the cluster and applications.

Example commands:
```bash
# Backup the cluster
# Check the upgrade path
# Upgrade control plane components
kubectl drain <node-name> --ignore-daemonsets
apt-get update && apt-get install -y kubeadm=1.21.x-00
kubeadm upgrade apply v1.21.x
kubectl uncordon <node-name>

# Upgrade kubelet and kubectl
apt-get update && apt-get install -y kubelet=1.21.x-00 kubectl=1.21.x-00
systemctl restart kubelet

# Verify the upgrade
kubectl get nodes
kubectl get pods --all-namespaces

# Run post-upgrade tests
# Validate cluster and application functionality
```
</details>
</details>
