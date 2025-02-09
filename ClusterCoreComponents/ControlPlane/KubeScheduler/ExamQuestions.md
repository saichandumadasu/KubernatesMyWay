# Scenario-Based Exam Questions and Answers for CKA Exam - KubeScheduler

## Question 1
**Scenario:** You have a Kubernetes cluster with multiple nodes. You need to ensure that a specific pod is always scheduled on a node with a particular label.

**Task:** Create a pod configuration that ensures the pod is scheduled on a node with the label `disktype=ssd`.

<details>
<summary>Answer:</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: my-pod
spec:
    containers:
    - name: my-container
        image: nginx
    nodeSelector:
        disktype: ssd
```

</details>

## Question 2
**Scenario:** You need to ensure that a pod is scheduled on a node that has at least 2 CPUs and 4Gi of memory available.

**Task:** Create a pod configuration that ensures the pod is scheduled on a node with the required resources.

<details>
<summary>Answer:</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: resource-pod
spec:
    containers:
    - name: my-container
        image: nginx
    resources:
        requests:
            memory: "4Gi"
            cpu: "2"
```

</details>

## Question 3
**Scenario:** You have a Kubernetes cluster and you need to ensure that a pod is scheduled on a node that is in a specific availability zone.

**Task:** Create a pod configuration that ensures the pod is scheduled on a node with the label `failure-domain.beta.kubernetes.io/zone=us-west-2a`.

<details>
<summary>Answer:</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: zone-pod
spec:
    containers:
    - name: my-container
        image: nginx
    nodeSelector:
        failure-domain.beta.kubernetes.io/zone: us-west-2a
```

</details>

## Question 4
**Scenario:** You need to ensure that a pod is scheduled on a node that does not have a specific taint.

**Task:** Create a pod configuration that tolerates the taint `key=value:NoSchedule`.

<details>
<summary>Answer:</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: tolerant-pod
spec:
    containers:
    - name: my-container
        image: nginx
    tolerations:
    - key: "key"
      operator: "Equal"
      value: "value"
      effect: "NoSchedule"
```

</details>

## Question 5
**Scenario:** You need to ensure that a pod is scheduled on a node that has a specific label and also tolerates a specific taint.

**Task:** Create a pod configuration that ensures the pod is scheduled on a node with the label `env=production` and tolerates the taint `env=production:NoSchedule`.

<details>
<summary>Answer:</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: production-pod
spec:
    containers:
    - name: my-container
        image: nginx
    nodeSelector:
        env: production
    tolerations:
    - key: "env"
      operator: "Equal"
      value: "production"
      effect: "NoSchedule"
```

</details>


## Question 6
**Scenario:** You are managing a Kubernetes cluster for a financial services company. You need to ensure that a critical pod is scheduled on a node that has both high memory and CPU capacity, and also ensure that the pod is not scheduled on nodes that are under maintenance.

**Task:** Create a pod configuration that ensures the pod is scheduled on a node with the label `tier=high-performance`, has at least 8 CPUs and 16Gi of memory available, and tolerates the taint `maintenance=true:NoSchedule`.

<details>
<summary>Answer:</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: critical-pod
spec:
    containers:
    - name: my-container
        image: nginx
    nodeSelector:
        tier: high-performance
    resources:
        requests:
            memory: "16Gi"
            cpu: "8"
    tolerations:
    - key: "maintenance"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
```

</details>

## Question 7
**Scenario:** You are working for a healthcare company that requires certain pods to be scheduled on nodes that are compliant with specific security standards. These nodes are labeled with `security=high` and have a taint `security=high:NoExecute` to prevent non-compliant pods from running on them.

**Task:** Create a pod configuration that ensures the pod is scheduled on a node with the label `security=high` and tolerates the taint `security=high:NoExecute`.

<details>
<summary>Answer:</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: secure-pod
spec:
    containers:
    - name: my-container
        image: nginx
    nodeSelector:
        security: high
    tolerations:
    - key: "security"
      operator: "Equal"
      value: "high"
      effect: "NoExecute"
```

</details>