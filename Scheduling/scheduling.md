# Kubernetes Scheduling

## Introduction
Kubernetes scheduling is a core component of Kubernetes that ensures Pods are assigned to Nodes in a cluster. The scheduler's role is to ensure that workloads are efficiently distributed across the available resources, optimizing for performance, availability, and resource utilization.

## Importance of Scheduling
Scheduling is crucial in Kubernetes for several reasons:
- **Resource Optimization**: Ensures that workloads are distributed in a way that optimizes the use of available resources.
- **High Availability**: Distributes workloads to avoid single points of failure.
- **Scalability**: Automatically adjusts to changes in the cluster, such as adding or removing nodes.
- **Performance**: Ensures that workloads are placed on nodes that have the necessary resources to run efficiently.

Without proper scheduling, workloads might end up on overloaded nodes, leading to performance degradation, resource contention, and potential downtime.

## Scheduling in Kubernetes
Kubernetes uses a two-step process for scheduling:
1. **Filtering**: Determines which nodes are eligible to run a given Pod based on resource requirements and constraints.
2. **Scoring**: Ranks the eligible nodes to find the most suitable one for the Pod.

### Filtering
Filtering involves checking each node against a set of criteria to determine if it can run the Pod. Criteria include:
- **Resource Requests and Limits**: Ensures the node has enough CPU and memory.
- **Node Affinity/Anti-Affinity**: Ensures the Pod is placed on a node that meets specific labels.
- **Taints and Tolerations**: Ensures the Pod can tolerate any taints on the node.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: example-pod
spec:
    containers:
    - name: example-container
        image: nginx
        resources:
            requests:
                memory: "64Mi"
                cpu: "250m"
            limits:
                memory: "128Mi"
                cpu: "500m"
    affinity:
        nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                    - key: disktype
                        operator: In
                        values:
                        - ssd
```
**Use Case**: This example is useful for ensuring that a Pod requiring high I/O performance is scheduled on nodes with SSDs.

### Scoring
Scoring involves ranking the eligible nodes based on various factors to find the best fit for the Pod. Factors include:
- **Resource Availability**: Nodes with more available resources are preferred.
- **Pod Affinity/Anti-Affinity**: Ensures Pods are placed close to or away from other Pods.
- **Custom Schedulers**: Allows custom logic for scoring nodes.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: example-pod
spec:
    containers:
    - name: example-container
        image: nginx
    affinity:
        podAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                    matchExpressions:
                    - key: app
                        operator: In
                        values:
                        - frontend
                topologyKey: "kubernetes.io/hostname"
```
**Use Case**: This example ensures that frontend Pods are scheduled on the same node to reduce latency and improve communication efficiency.

## Manual Scheduling
Manual scheduling allows you to specify the exact node on which a Pod should run. This can be useful in scenarios where you need precise control over Pod placement, such as for performance testing, debugging, or when certain nodes have specialized hardware.

### When to Use Manual Scheduling
- **Performance Testing**: To ensure that a Pod runs on a specific node with known performance characteristics.
- **Debugging**: To isolate a Pod on a specific node for troubleshooting.
- **Specialized Hardware**: When certain nodes have specialized hardware (e.g., GPUs) that are required by the Pod.

### How to Use Manual Scheduling
Manual scheduling is done by setting the `nodeName` field in the Pod specification. This field specifies the name of the node where the Pod should be scheduled.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: manual-scheduled-pod
spec:
    containers:
    - name: example-container
        image: nginx
    nodeName: "node-1"
```
**Use Case**: This example is useful for ensuring that a Pod runs on a specific node for performance testing or debugging purposes.

## Labels and Selectors
Labels and selectors are fundamental concepts in Kubernetes that are used to organize and select subsets of objects, such as Pods and Nodes. They play a crucial role in scheduling by allowing you to define constraints and preferences for Pod placement.

### Labels
Labels are key-value pairs that are attached to objects, such as Pods and Nodes. They are used to identify and group objects based on specific attributes.

#### Example
```yaml
apiVersion: v1
kind: Node
metadata:
    name: node-1
    labels:
        disktype: ssd
        region: us-west
```
**Use Case**: This example is useful for categorizing nodes based on their disk type and region, which can be used for scheduling decisions.

### Selectors
Selectors are used to filter and select objects based on their labels. There are two types of selectors: equality-based and set-based.

#### Equality-Based Selectors
Equality-based selectors allow you to select objects that have a specific label with a specific value.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: example-pod
spec:
    containers:
    - name: example-container
        image: nginx
    affinity:
        nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                    - key: disktype
                        operator: In
                        values:
                        - ssd
```
**Use Case**: This example ensures that a Pod is scheduled on nodes with SSDs for better performance.

#### Set-Based Selectors
Set-based selectors allow you to select objects based on a set of values.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: example-pod
spec:
    containers:
    - name: example-container
        image: nginx
    affinity:
        nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                    - key: region
                        operator: In
                        values:
                        - us-west
                        - us-east
```
**Use Case**: This example ensures that a Pod is scheduled on nodes in either the `us-west` or `us-east` regions.

### When to Use Labels and Selectors
- **Organizing Resources**: Use labels to organize and categorize resources based on attributes such as environment, region, or hardware type.
- **Scheduling Constraints**: Use selectors to define constraints for Pod placement based on node attributes.
- **Service Discovery**: Use labels to identify and select Pods for service discovery and load balancing.

## Taints and Tolerations
Taints and tolerations work together to ensure that Pods are not scheduled onto inappropriate nodes. Taints are applied to nodes, and tolerations are applied to Pods.

### Taints
Taints are key-value pairs that are applied to nodes to repel Pods that do not tolerate them.

#### Example
```yaml
apiVersion: v1
kind: Node
metadata:
    name: node-1
spec:
    taints:
    - key: "key1"
      value: "value1"
      effect: "NoSchedule"
```
**Use Case**: This example is useful for ensuring that only specific Pods that tolerate the taint are scheduled on the node `node-1`.

### Tolerations
Tolerations are applied to Pods to allow them to be scheduled on nodes with matching taints.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: example-pod
spec:
    containers:
    - name: example-container
        image: nginx
    tolerations:
    - key: "key1"
      operator: "Equal"
      value: "value1"
      effect: "NoSchedule"
```
**Use Case**: This example ensures that the Pod `example-pod` can be scheduled on nodes with the taint `key1=value1:NoSchedule`.

## Node Affinity and Anti-Affinity
Node affinity and anti-affinity allow you to specify rules about which nodes a Pod can be scheduled on based on node labels.

### Node Affinity
Node affinity is used to attract Pods to nodes with specific labels.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: example-pod
spec:
    containers:
    - name: example-container
        image: nginx
    affinity:
        nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                    - key: disktype
                        operator: In
                        values:
                        - ssd
```
**Use Case**: This example ensures that a Pod is scheduled on nodes with SSDs for better performance.

### Node Anti-Affinity
Node anti-affinity is used to repel Pods from nodes with specific labels.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: example-pod
spec:
    containers:
    - name: example-container
        image: nginx
    affinity:
        nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                    - key: disktype
                        operator: NotIn
                        values:
                        - hdd
```
**Use Case**: This example ensures that a Pod is not scheduled on nodes with HDDs, which might have lower performance.

## Combined Use Case: Affinity and Taints/Tolerations
In some scenarios, you might need to use both affinity and taints/tolerations to achieve the desired scheduling behavior.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: combined-example-pod
spec:
    containers:
    - name: example-container
        image: nginx
    affinity:
        nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                    - key: disktype
                        operator: In
                        values:
                        - ssd
    tolerations:
    - key: "special"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
```
**Use Case**: This example ensures that the Pod `combined-example-pod` is scheduled on nodes with SSDs and can tolerate nodes that have the `special=true:NoSchedule` taint. This is useful for scenarios where you want to ensure high performance (SSD) and allow scheduling on nodes with special configurations.

## Resource Limits and Requests
Resource limits and requests are used to specify the minimum and maximum amount of CPU and memory resources that a Pod requires. They play a crucial role in scheduling by ensuring that Pods are placed on nodes that have sufficient resources to meet their needs.

### Resource Requests
Resource requests specify the minimum amount of CPU and memory resources that a Pod requires. The scheduler uses these values to determine which nodes have enough available resources to run the Pod.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: resource-request-pod
spec:
    containers:
    - name: example-container
        image: nginx
        resources:
            requests:
                memory: "64Mi"
                cpu: "250m"
```
**Use Case**: This example ensures that the Pod `resource-request-pod` is scheduled on a node that has at least 64Mi of memory and 250m of CPU available.

### Resource Limits
Resource limits specify the maximum amount of CPU and memory resources that a Pod can use. The scheduler uses these values to ensure that the Pod does not exceed the available resources on the node.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: resource-limit-pod
spec:
    containers:
    - name: example-container
        image: nginx
        resources:
            limits:
                memory: "128Mi"
                cpu: "500m"
```
**Use Case**: This example ensures that the Pod `resource-limit-pod` does not use more than 128Mi of memory and 500m of CPU, preventing it from overloading the node.

### Combined Resource Requests and Limits
Combining resource requests and limits allows you to specify both the minimum and maximum amount of resources that a Pod requires and can use.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: combined-resource-pod
spec:
    containers:
    - name: example-container
        image: nginx
        resources:
            requests:
                memory: "64Mi"
                cpu: "250m"
            limits:
                memory: "128Mi"
                cpu: "500m"
```
**Use Case**: This example ensures that the Pod `combined-resource-pod` is scheduled on a node that has at least 64Mi of memory and 250m of CPU available, and it does not use more than 128Mi of memory and 500m of CPU.

## Differences Between Taints and Affinity
- **Taints and Tolerations**: Taints are applied to nodes to repel Pods, and tolerations are applied to Pods to allow them to be scheduled on nodes with matching taints.
- **Node Affinity and Anti-Affinity**: Node affinity is used to attract Pods to nodes with specific labels, while node anti-affinity is used to repel Pods from nodes with specific labels.


## DaemonSets and Static Pods

### DaemonSets
A DaemonSet ensures that a copy of a Pod runs on all (or some) Nodes in the cluster. When you add a Node to the cluster, the DaemonSet automatically adds the Pod to the new Node. When you remove a Node from the cluster, the DaemonSet automatically cleans up the Pod that ran on that Node.

#### Example
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
    name: example-daemonset
spec:
    selector:
        matchLabels:
            name: example-daemonset
    template:
        metadata:
            labels:
                name: example-daemonset
        spec:
            containers:
            - name: example-container
                image: nginx
```
**Use Case**: This example ensures that an `nginx` container runs on every Node in the cluster. This is useful for logging, monitoring, or other system-level services that need to run on every Node.

### Static Pods
Static Pods are managed directly by the kubelet on a specific Node, without the API server being aware of them. They are defined in a manifest file that is placed in a specific directory on the Node. The kubelet watches this directory and automatically creates/deletes the Static Pods as needed.

#### Example
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: static-pod
spec:
    containers:
    - name: example-container
        image: nginx
```
**Use Case**: This example ensures that an `nginx` container runs on a specific Node. This is useful for critical system Pods that need to be always running, even if the API server is down.

### Real-World Use Cases
- **DaemonSets**: Use DaemonSets for deploying logging agents (e.g., Fluentd), monitoring agents (e.g., Prometheus Node Exporter), or network plugins (e.g., Calico) that need to run on every Node.
- **Static Pods**: Use Static Pods for critical system components like etcd in a Kubernetes control plane, where you need to ensure the Pod runs on a specific Node and remains running even if the API server is unavailable.


## Multiple Schedulers and Scheduler Profiles

### Multiple Schedulers
Kubernetes allows you to run multiple schedulers within a cluster. This can be useful for custom scheduling requirements or to handle different types of workloads with specialized scheduling logic.

#### Why Use Multiple Schedulers
- **Custom Scheduling Logic**: Implement custom scheduling algorithms tailored to specific workloads.
- **Workload Separation**: Separate different types of workloads to different schedulers for better resource management.
- **Testing and Development**: Test new scheduling algorithms without affecting the default scheduler.

#### How to Use Multiple Schedulers
To use multiple schedulers, you need to deploy additional scheduler instances and configure Pods to use them.

#### Example
1. **Deploy a Custom Scheduler**:
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: custom-scheduler
    namespace: kube-system
spec:
    containers:
    - name: custom-scheduler
      image: custom-scheduler:latest
      command:
      - /usr/local/bin/custom-scheduler
      - --scheduler-name=custom-scheduler
```
2. **Configure Pods to Use the Custom Scheduler**:
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: custom-scheduled-pod
spec:
    schedulerName: custom-scheduler
    containers:
    - name: example-container
      image: nginx
```
**Use Case**: This example ensures that the Pod `custom-scheduled-pod` is scheduled using the `custom-scheduler`, allowing for custom scheduling logic.

### Scheduler Profiles
Scheduler profiles allow you to define different scheduling policies within a single scheduler instance. Each profile can have its own set of plugins and configurations.

#### Why Use Scheduler Profiles
- **Flexible Scheduling Policies**: Define multiple scheduling policies within a single scheduler.
- **Optimized Scheduling**: Optimize scheduling for different types of workloads using different profiles.
- **Simplified Management**: Manage multiple scheduling policies without deploying multiple schedulers.

#### How to Use Scheduler Profiles
Scheduler profiles are defined in the scheduler configuration file. Each profile can be referenced by Pods.

#### Example
1. **Define Scheduler Profiles**:
```yaml
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
profiles:
- name: high-priority
  plugins:
    queueSort:
      enabled:
      - name: PrioritySort
- name: low-priority
  plugins:
    queueSort:
      enabled:
      - name: DefaultSort
```
2. **Configure Pods to Use a Specific Profile**:
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: high-priority-pod
spec:
    schedulerName: default-scheduler
    schedulingProfile: high-priority
    containers:
    - name: example-container
      image: nginx
```
**Use Case**: This example ensures that the Pod `high-priority-pod` is scheduled using the `high-priority` profile, which uses the `PrioritySort` plugin for queue sorting.

### When to Use Multiple Schedulers and Scheduler Profiles
- **Custom Scheduling Requirements**: Use multiple schedulers for custom scheduling logic that cannot be achieved with the default scheduler.
- **Workload Optimization**: Use scheduler profiles to optimize scheduling for different types of workloads within a single scheduler instance.
- **Testing and Development**: Use multiple schedulers and profiles to test new scheduling algorithms and policies without affecting the default scheduler.

By leveraging multiple schedulers and scheduler profiles, you can achieve greater flexibility and optimization in scheduling workloads in your Kubernetes cluster.

## Admission Controllers in Kubernetes

Admission controllers are plugins that govern and enforce how the cluster is used. They intercept requests to the Kubernetes API server before any object is persisted, but after the request is authenticated and authorized. Admission controllers can modify the request object or reject the request altogether.

### Types of Admission Controllers

1. **Mutating Admission Controllers**: These controllers can modify the incoming request object before it is persisted.
2. **Validating Admission Controllers**: These controllers validate the request object and can reject it if it does not meet certain criteria.

### Mutating Admission Controllers

Mutating admission controllers are used to modify or set defaults on the objects being created or updated. They are useful for ensuring that certain fields are set or modified according to specific policies.

#### When to Use Mutating Admission Controllers
- **Setting Defaults**: Automatically set default values for certain fields if they are not provided.
- **Injecting Sidecars**: Automatically inject sidecar containers into Pods for logging, monitoring, or other purposes.
- **Modifying Labels/Annotations**: Add or modify labels and annotations on objects for better organization or tracking.

#### When Not to Use Mutating Admission Controllers
- **Complex Validations**: If the primary goal is to validate the object without modifying it, use a validating admission controller instead.
- **Security Concerns**: Avoid using mutating controllers for security-sensitive modifications that should be explicitly defined by the user.

#### How to Use Mutating Admission Controllers
Mutating admission controllers are typically implemented as webhooks. You need to deploy the webhook server and configure the Kubernetes API server to use it.

#### Example: Injecting a Sidecar Container
1. **Webhook Configuration**:
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: sidecar-injector-webhook
webhooks:
  - name: sidecar-injector.example.com
    clientConfig:
      service:
        name: sidecar-injector
        namespace: default
        path: "/mutate"
      caBundle: <base64-encoded-ca-cert>
    rules:
      - operations: ["CREATE"]
        apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
    admissionReviewVersions: ["v1"]
    sideEffects: None
```
2. **Webhook Server**:
```go
package main

import (
    "encoding/json"
    "net/http"
    "k8s.io/api/admission/v1"
    "k8s.io/api/core/v1"
)

func mutatePods(w http.ResponseWriter, r *http.Request) {
    var admissionReview v1.AdmissionReview
    if err := json.NewDecoder(r.Body).Decode(&admissionReview); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    pod := &v1.Pod{}
    if err := json.Unmarshal(admissionReview.Request.Object.Raw, pod); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    // Inject sidecar container
    sidecar := v1.Container{
        Name:  "sidecar",
        Image: "sidecar-image",
    }
    pod.Spec.Containers = append(pod.Spec.Containers, sidecar)

    patch, err := json.Marshal([]map[string]interface{}{
        {"op": "add", "path": "/spec/containers/-", "value": sidecar},
    })
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    admissionResponse := v1.AdmissionResponse{
        Allowed: true,
        Patch:   patch,
        PatchType: func() *v1.PatchType {
            pt := v1.PatchTypeJSONPatch
            return &pt
        }(),
    }

    admissionReview.Response = &admissionResponse
    if err := json.NewEncoder(w).Encode(admissionReview); err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}

func main() {
    http.HandleFunc("/mutate", mutatePods)
    http.ListenAndServe(":8080", nil)
}
```

### Validating Admission Controllers

Validating admission controllers are used to enforce policies by validating the objects being created or updated. They can reject requests that do not meet certain criteria.

#### When to Use Validating Admission Controllers
- **Policy Enforcement**: Ensure that objects meet specific policies before they are persisted.
- **Security**: Validate security-related configurations, such as ensuring certain labels or annotations are present.
- **Resource Quotas**: Validate that resource requests and limits are within acceptable ranges.

#### When Not to Use Validating Admission Controllers
- **Modifying Objects**: If you need to modify the object, use a mutating admission controller instead.
- **Performance Concerns**: Avoid complex validations that could significantly impact the performance of the API server.

#### How to Use Validating Admission Controllers
Validating admission controllers are also implemented as webhooks. You need to deploy the webhook server and configure the Kubernetes API server to use it.

#### Example: Enforcing Resource Limits
1. **Webhook Configuration**:
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: resource-limits-webhook
webhooks:
  - name: resource-limits.example.com
    clientConfig:
      service:
        name: resource-limits
        namespace: default
        path: "/validate"
      caBundle: <base64-encoded-ca-cert>
    rules:
      - operations: ["CREATE", "UPDATE"]
        apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
    admissionReviewVersions: ["v1"]
    sideEffects: None
```
2. **Webhook Server**:
```go
package main

import (
    "encoding/json"
    "net/http"
    "k8s.io/api/admission/v1"
    "k8s.io/api/core/v1"
)

func validatePods(w http.ResponseWriter, r *http.Request) {
    var admissionReview v1.AdmissionReview
    if err := json.NewDecoder(r.Body).Decode(&admissionReview); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    pod := &v1.Pod{}
    if err := json.Unmarshal(admissionReview.Request.Object.Raw, pod); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    for _, container := range pod.Spec.Containers {
        if container.Resources.Limits.Cpu().MilliValue() > 500 {
            admissionResponse := v1.AdmissionResponse{
                Allowed: false,
                Result: &metav1.Status{
                    Message: "CPU limit exceeds 500m",
                },
            }
            admissionReview.Response = &admissionResponse
            if err := json.NewEncoder(w).Encode(admissionReview); err != nil {
                http.Error(w, err.Error(), http.StatusInternalServerError)
            }
            return
        }
    }

    admissionResponse := v1.AdmissionResponse{Allowed: true}
    admissionReview.Response = &admissionResponse
    if err := json.NewEncoder(w).Encode(admissionReview); err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}

func main() {
    http.HandleFunc("/validate", validatePods)
    http.ListenAndServe(":8080", nil)
}
```

### Real-World Use Cases

- **Mutating Admission Controllers**:
  - **Istio Sidecar Injection**: Automatically inject Istio sidecar containers into Pods for service mesh functionality.
  - **Default Resource Requests/Limits**: Set default resource requests and limits for Pods that do not specify them.

- **Validating Admission Controllers**:
  - **Security Policies**: Ensure that Pods have specific security contexts, such as running as non-root.
  - **Resource Quotas**: Validate that resource requests and limits are within predefined quotas.

By using admission controllers effectively, you can enforce policies, ensure security, and maintain consistency across your Kubernetes cluster.

## Conclusion
Kubernetes scheduling is a vital component that ensures efficient and effective distribution of workloads across a cluster. Proper scheduling leads to optimized resource usage, high availability, and improved performance. Understanding and configuring scheduling policies, including manual scheduling, labels and selectors, taints and tolerations, node affinity and anti-affinity, and resource limits and requests, can significantly impact the reliability and efficiency of your Kubernetes deployments.