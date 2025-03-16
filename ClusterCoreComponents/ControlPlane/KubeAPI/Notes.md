---
title: KubeAPI Server Notes
---

# KubeAPI Server Notes

## Overview
The Kubernetes API server is a component of the Kubernetes control plane that exposes the Kubernetes API. It is the front-end for the Kubernetes control plane and is responsible for handling all the RESTful requests to the Kubernetes cluster.

The kube-api server is the central hub of the Kubernetes cluster that exposes the Kubernetes API. It is highly scalable and can handle a large number of concurrent requests.

End users, and other cluster components, talk to the cluster via the API server. Very rarely, monitoring systems and third-party services may talk to API servers to interact with the cluster.

So when you use `kubectl` to manage the cluster, at the backend you are actually communicating with the API server through HTTP REST APIs. However, the internal cluster components like the scheduler, controller, etc., talk to the API server using gRPC.

The communication between the API server and other components in the cluster happens over TLS to prevent unauthorized access to the cluster.

### Kubernetes API Server Responsibilities

- **API Management**: Exposes the cluster API endpoint and handles all API requests. The API is versioned and supports multiple API versions simultaneously.
- **Authentication and Authorization**: Uses client certificates, bearer tokens, and HTTP Basic Authentication for authentication, and ABAC and RBAC evaluation for authorization.
- **Processing API Requests**: Validates data for the API objects like pods, services, etc., using Validation and Mutation Admission controllers.
- **Coordination**: Coordinates all the processes between the control plane and worker node components.
- **Aggregation Layer**: Allows you to extend Kubernetes API to create custom API resources and controllers.
- **etcd Connection**: The only component that the kube-apiserver initiates a connection to is the etcd component. All the other components connect to the API server.
- **Resource Watching**: Supports watching resources for changes. Clients can establish a watch on specific resources and receive real-time notifications when those resources are created, modified, or deleted.
- **Built-in API Server Proxy**: Part of the API server process, primarily used to enable access to ClusterIP services from outside the cluster.

### Common Commands

- **Start API Server Proxy**:
    ```sh
    kubectl proxy --port=8080
    ```

- **Port Forwarding**:
    ```sh
    kubectl port-forward <pod-name> 8080:80
    ```

- **Execute Commands in a Pod**:
    ```sh
    kubectl exec -it <pod-name> -- /bin/bash
    ```

### Security Note

To reduce the cluster attack surface, it is crucial to secure the API server. The Shadowserver Foundation has conducted an experiment that discovered 380,000 publicly accessible Kubernetes API servers.

### Key Responsibilities

1. **Handling RESTful Requests**: The API server processes RESTful requests from users, nodes, and other components.
2. **Validating and Configuring Data**: It validates and configures the data for the API objects, including pods, services, replication controllers, and others.
3. **Serving the Kubernetes API**: The API server serves the Kubernetes API, which is used by all the other components to interact with the cluster.

### How does the API Server work with Kubernetes?

The API server is the central management entity that receives all the administrative commands for the Kubernetes cluster. It exposes the Kubernetes API, which is used by the kubectl command-line tool, other components, and users to interact with the cluster.

In a nutshell, here is what you need to know about the API server:

- The API server is the only component that interacts directly with the etcd datastore.
- It validates and configures the data for the API objects.
- It provides the frontend to the cluster’s shared state through which all other components interact.
- It implements an interface, so different tools and libraries can readily communicate with it.

## Index
- [Installation of KubeAPI Server](#installation-of-kubeapi-server)
- [Single KubeAPI Server for Kubernetes](#single-kubeapi-server-for-kubernetes)
- [High Availability KubeAPI Server](#high-availability-kubeapi-server)
- [Securing Communication for KubeAPI Server](#securing-communication-for-kubeapi-server)
- [Connecting to KubeAPI Server Using `kubectl`](#connecting-to-kubeapi-server-using-kubectl)
- [Requesting Access to KubeAPI Server for New Users](#requesting-access-to-kubeapi-server-for-new-users)
- [System Administrator (SA) Access to KubeAPI Server](#system-administrator-sa-access-to-kubeapi-server)
- [`kubectl` Cheat Sheet](#kubectl-cheat-sheet)
- [Understanding CIDR (Classless Inter-Domain Routing)](#understanding-cidr-classless-inter-domain-routing)

## Installation of KubeAPI Server

To install the KubeAPI server, follow these steps:

1. **Download Kubernetes binaries**:
    Download the latest version of Kubernetes binaries from the official Kubernetes releases page:
    ```sh
    wget https://dl.k8s.io/v1.22.0/kubernetes-server-linux-amd64.tar.gz
    ```

2. **Extract the tarball**:
    ```sh
    tar xvf kubernetes-server-linux-amd64.tar.gz
    ```

3. **Move the binaries**:
    ```sh
    sudo mv kubernetes/server/bin/kube-apiserver /usr/local/bin/
    ```

4. **Verify the installation**:
    ```sh
    kube-apiserver --version
    ```

5. **Create a systemd service file**:
    Create a file at `/etc/systemd/system/kube-apiserver.service` with the following content:
    ```ini
    [Unit]
    Description=Kubernetes API Server
    Documentation=https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/kube-apiserver \
      --advertise-address=<your-advertise-address> \
      --allow-privileged=true \
      --apiserver-count=3 \
      --audit-log-path=/var/log/kube-apiserver-audit.log \
      --authorization-mode=Node,RBAC \
      --client-ca-file=/etc/kubernetes/pki/ca.crt \
      --enable-admission-plugins=NodeRestriction \
      --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt \
      --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt \
      --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key \
      --etcd-servers=https://127.0.0.1:2379 \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key \
      --runtime-config=api/all=true \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub \
      --service-cluster-ip-range=10.96.0.0/12 \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.crt \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    Restart=always
    RestartSec=5
    LimitNOFILE=40000

    [Install]
    WantedBy=multi-user.target
    ```

6. **Start and enable the KubeAPI server service**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl start kube-apiserver
    sudo systemctl enable kube-apiserver
    ```

7. **Check the KubeAPI server service status**:
    ```sh
    sudo systemctl status kube-apiserver
    ```

Following these steps will install and run the KubeAPI server on your system.

## Single KubeAPI Server for Kubernetes

To set up a single KubeAPI server for Kubernetes, follow these steps:

1. **Install KubeAPI Server**:
    Follow the installation steps mentioned above to install the KubeAPI server on your system.

2. **Configure KubeAPI Server**:
    Edit the `/etc/systemd/system/kube-apiserver.service` file to include the necessary configuration.

3. **Start and enable the KubeAPI server service**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl start kube-apiserver
    sudo systemctl enable kube-apiserver
    ```

4. **Verify the KubeAPI server service status**:
    ```sh
    sudo systemctl status kube-apiserver
    ```

5. **Start K8s with single KubeAPI server**
    ```sh
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr=192.168.0.0/16
    ```

## High Availability KubeAPI Server

To set up a high availability KubeAPI server cluster for Kubernetes, follow these steps:

1. **Install KubeAPI Server on all nodes**:
    Follow the installation steps mentioned above to install the KubeAPI server on each node in your cluster.

2. **Configure KubeAPI Server on each node**:
    Edit the `/etc/systemd/system/kube-apiserver.service` file on each node to include the necessary configuration.

3. **Start and enable the KubeAPI server service on each node**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl start kube-apiserver
    sudo systemctl enable kube-apiserver
    ```

4. **Verify the KubeAPI server service status on each node**:
    ```sh
    sudo systemctl status kube-apiserver
    ```

5. **Start K8s with high availability KubeAPI servers**:
    ```sh
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr=192.168.0.0/16 --control-plane-endpoint <load-balancer-dns>:6443
    ```
## Understanding CIDR (Classless Inter-Domain Routing)

CIDR stands for Classless Inter-Domain Routing. It's a way to allocate IP addresses and route IP packets. Think of it as a method to organize and manage IP addresses more efficiently.

### What is an IP Address?

An IP address is like a home address for your computer on the internet. It helps other computers find and communicate with it. For example, `192.168.1.1` is an IP address.

### What is a Subnet Mask?

A subnet mask helps divide an IP address into two parts: the network part and the host part. For example, in the IP address `192.168.1.1` with a subnet mask of `255.255.255.0`, `192.168.1` is the network part, and `1` is the host part.

### What is CIDR?

CIDR notation combines an IP address and a subnet mask into a single string. It looks like this: `192.168.1.0/24`. Here, `192.168.1.0` is the network address, and `/24` indicates the subnet mask.

### How to Read CIDR Notation?

- The number after the slash (`/`) tells you how many bits are in the network part of the address.
- For example, `/24` means the first 24 bits are the network part, and the remaining bits are for hosts.

### Examples

1. **`192.168.1.0/24`**:
    - Network part: `192.168.1`
    - Host part: `0`
    - This means you can have IP addresses from `192.168.1.1` to `192.168.1.254`.
    - **Math Expression**: `2^(32-24) - 2 = 254` usable IP addresses.

2. **`10.0.0.0/8`**:
    - Network part: `10`
    - Host part: `0.0.0`
    - This means you can have IP addresses from `10.0.0.1` to `10.255.255.254`.
    - **Math Expression**: `2^(32-8) - 2 = 16,777,214` usable IP addresses.

3. **`172.16.0.0/16`**:
    - Network part: `172.16`
        - Host part: `0.0.0`
            - This means you can have IP addresses from `172.16.0.1` to `172.16.255.254`.

        ### Determining Network and Host Parts

        To determine the network and host parts of an IP address based on the CIDR notation (e.g., `/24`):

        - **Network Part**: The number after the slash (`/`) indicates how many bits are used for the network part. For `/24`, the first 24 bits are the network part.
        - **Host Part**: The remaining bits are used for the host part. For `/24`, the last 8 bits are for the host part.

        For example, in `192.168.1.0/24`:
        - The first 24 bits (`192.168.1`) are the network part.
        - The last 8 bits (`0`) are the host part.

        This allows for 256 possible addresses (2^8), but the first address is reserved for the network and the last address is reserved for the broadcast, leaving 254 usable IP addresses.

        For example, in `10.0.0.0/8`:
        - The first 8 bits (`10`) are the network part.
        - The last 24 bits (`0.0.0`) are the host part.

        This allows for 16,777,216 possible addresses (2^24), but the first address is reserved for the network and the last address is reserved for the broadcast, leaving 16,777,214 usable IP addresses.

        ### Mathematical Explanation

        To calculate the number of usable IP addresses in a subnet, use the formula:

        \[ \text{Usable IP addresses} = 2^{(\text{Total bits} - \text{Network bits})} - 2 \]

        Where:
        - **Total bits**: The total number of bits in the IP address (32 for IPv4).
        - **Network bits**: The number of bits used for the network part (given by the CIDR notation).

        For example, for `192.168.1.0/24`:
        - Total bits = 32
        - Network bits = 24

        \[ \text{Usable IP addresses} = 2^{(32 - 24)} - 2 = 2^8 - 2 = 256 - 2 = 254 \]

        For example, for `10.0.0.0/8`:
        - Total bits = 32
        - Network bits = 8

        \[ \text{Usable IP addresses} = 2^{(32 - 8)} - 2 = 2^{24} - 2 = 16,777,216 - 2 = 16,777,214 \]

        Thus, there are 254 usable IP addresses in the `192.168.1.0/24` subnet and 16,777,214 usable IP addresses in the `10.0.0.0/8` subnet.

        ### Example with Bits

        Let's take the example of `192.168.1.0/24` and break it down into bits:

        - **IP Address**: `192.168.1.0`
        - **CIDR Notation**: `/24`

        In binary, `192.168.1.0` is:
        ```
        11000000.10101000.00000001.00000000
        ```

        The `/24` indicates that the first 24 bits are the network part:
        ```
        11000000.10101000.00000001 | 00000000
        ```

        - Network part: `11000000.10101000.00000001` (192.168.1)
        - Host part: `00000000` (0)

        This means the network address is `192.168.1.0` and the range of usable IP addresses is from `192.168.1.1` to `192.168.1.254`.

        Let's take the example of `10.0.0.0/8` and break it down into bits:

        - **IP Address**: `10.0.0.0`
        - **CIDR Notation**: `/8`

        In binary, `10.0.0.0` is:
        ```
        00001010.00000000.00000000.00000000
        ```

        The `/8` indicates that the first 8 bits are the network part:
        ```
        00001010 | 00000000.00000000.00000000
        ```

        - Network part: `00001010` (10)
        - Host part: `00000000.00000000.00000000` (0.0.0)

        This means the network address is `10.0.0.0` and the range of usable IP addresses is from `10.0.0.1` to `10.255.255.254`.

### Why Use CIDR?

- **Efficiency**: CIDR allows for more efficient use of IP addresses.
- **Flexibility**: It provides flexibility in defining network sizes.
- **Simplification**: It simplifies routing by reducing the number of routing table entries.

### Summary

CIDR is a method to manage IP addresses efficiently. It combines an IP address and a subnet mask into a single notation, making it easier to understand and use. By using CIDR, you can create networks of different sizes and manage them more effectively.



Following these steps will set up a single or high availability KubeAPI server cluster for Kubernetes.

## Securing Communication for KubeAPI Server

To secure communication for the KubeAPI server, you should enable TLS to encrypt data in transit and authenticate clients. Here are the steps to secure the KubeAPI server:

1. **Generate Certificates**:
    Generate CA, server, and client certificates. You can use tools like `cfssl` or `openssl` to generate these certificates.

    **Generate Certificates with OpenSSL**:
    Generate CA, server, and client certificates using `openssl`. These certificates are essential for securing communication between the KubeAPI server and clients by enabling TLS.

    **Generate CA Certificate**:
    ```sh
    openssl genpkey -algorithm RSA -out ca.key
    openssl req -x509 -new -nodes -key ca.key -subj "/CN=kube-ca" -days 365 -out ca.crt
    ```

    **Generate Server Certificate**:
    ```sh
    openssl genpkey -algorithm RSA -out server.key
    openssl req -new -key server.key -subj "/CN=kube-apiserver" -out server.csr
    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
    ```

    **Generate Client Certificate**:
    ```sh
    openssl genpkey -algorithm RSA -out client.key
    openssl req -new -key client.key -subj "/CN=kube-client" -out client.csr
    openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365
    ```

2. **Configure KubeAPI Server to Use Certificates**:
    Edit the `/etc/systemd/system/kube-apiserver.service` file to include the following configuration:
    ```ini
    [Unit]
    Description=Kubernetes API Server
    Documentation=https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/kube-apiserver \
      --advertise-address=<your-advertise-address> \
      --allow-privileged=true \
      --apiserver-count=3 \
      --audit-log-path=/var/log/kube-apiserver-audit.log \
      --authorization-mode=Node,RBAC \
      --client-ca-file=/etc/kubernetes/pki/ca.crt \
      --enable-admission-plugins=NodeRestriction \
      --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt \
      --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt \
      --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key \
      --etcd-servers=https://127.0.0.1:2379 \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key \
      --runtime-config=api/all=true \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub \
      --service-cluster-ip-range=10.96.0.0/12 \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.crt \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    Restart=always
    RestartSec=5
    LimitNOFILE=40000

    [Install]
    WantedBy=multi-user.target
    ```

3. **Restart KubeAPI Server Service**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl restart kube-apiserver
    ```

## Connecting to KubeAPI Server Using `kubectl`

To connect to the KubeAPI server using `kubectl`, follow these steps:

1. **Install `kubectl`**:
    Install `kubectl` on your machine. You can download it from the official Kubernetes releases page.

2. **Set Environment Variables**:
    Set the necessary environment variables to point to the KubeAPI server endpoints and certificates:
    ```sh
    export KUBECONFIG=/path/to/kubeconfig
    ```

3. **Connect to KubeAPI Server**:
    Use `kubectl` to interact with the KubeAPI server:
    ```sh
    kubectl get nodes
    ```

## Requesting Access to KubeAPI Server for New Users

If a new user joins the organization and needs access to the KubeAPI server, follow these steps:

1. **User Requests Access**:
    The new user should request access by contacting the system administrator (SA) or the relevant team.

2. **Generate Certificates**:
    The SA generates client certificates for the new user using `openssl`. Follow these steps:

    **Generate Client Certificate for new user**:
    ```sh
    openssl genpkey -algorithm RSA -out newuser-client.key
    openssl req -new -key newuser-client.key -subj "/CN=newuser" -out newuser-client.csr
    openssl x509 -req -in newuser-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out newuser-client.crt -days 365

    3. **Distribute Certificates**:
        The SA securely distributes the client certificates (`newuser-client.crt`, `newuser-client.key`, and `ca.crt`) to the new user. These certificates should be placed in a secure directory, for example, `/home/newuser/.kube/`.

    4. **Create Kubeconfig File**:
        The new user creates a kubeconfig file at `/home/newuser/.kube/config` with the following content:
        ```yaml
        apiVersion: v1
        clusters:
        - cluster:
            certificate-authority: /home/newuser/.kube/ca.crt
            server: https://<kubeapi-server-endpoint>:6443
          name: kubernetes
        contexts:
        - context:
            cluster: kubernetes
            user: newuser
          name: newuser-context
        current-context: newuser-context
        kind: Config
        preferences: {}
        users:
        - name: newuser
          user:
            client-certificate: /home/newuser/.kube/newuser-client.crt
            client-key: /home/newuser/.kube/newuser-client.key
        ```

    5. **Set Environment Variables**:
        The new user sets the environment variables to point to the kubeconfig file:
        ```sh
        export KUBECONFIG=/home/newuser/.kube/config
        ```

    6. **Connect to KubeAPI Server**:
        The new user uses `kubectl` to interact with the KubeAPI server:
        ```sh
        kubectl get nodes
        ```


## System Administrator (SA) Access to KubeAPI Server

For a system administrator (SA) to access the KubeAPI server, follow these steps:

1. **Install `kubectl`**:
    Install `kubectl` on the SA's machine.

2. **Set Environment Variables**:
    Set the environment variables to point to the KubeAPI server endpoints and certificates:
    ```sh
    export KUBECONFIG=/path/to/kubeconfig
    ```

3. **Connect to KubeAPI Server**:
    Use `kubectl` to interact with the KubeAPI server:
    ```sh
    kubectl get nodes
    ```

By following these steps, users, admins, and system administrators can securely connect to and interact with the KubeAPI server using `kubectl`.

## `kubectl` Cheat Sheet

### Basic Commands

- **Get cluster information**:
    ```sh
    kubectl cluster-info
    ```

- **Get nodes**:
    ```sh
    kubectl get nodes
    ```

- **Get pods in all namespaces**:
    ```sh
    kubectl get pods --all-namespaces
    ```

- **Describe a pod**:
    ```sh
    kubectl describe pod <pod-name>
    ```

- **Create a resource from a file**:
    ```sh
    kubectl apply -f <file>
    ```

- **Delete a resource**:
    ```sh
    kubectl delete -f <file>
    ```

### Cluster Management

- **Drain a node**:
    ```sh
    kubectl drain <node-name> --ignore-daemonsets
    ```

- **Cordon a node**:
    ```sh
    kubectl cordon <node-name>
    ```

- **Uncordon a node**:
    ```sh
    kubectl uncordon <node-name>
    ```

### Logs and Monitoring

- **Get logs for a pod**:
    ```sh
    kubectl logs <pod-name>
    ```

- **Stream logs for a pod**:
    ```sh
    kubectl logs -f <pod-name>
    ```

- **Get events**:
    ```sh
    kubectl get events
    ```

### Config Management

- **View current context**:
    ```sh
    kubectl config current-context
    ```

- **Set a new context**:
    ```sh
    kubectl config use-context <context-name>
    ```

### Environment Variables

- **Set Kubeconfig**:
    ```sh
    export KUBECONFIG=/path/to/kubeconfig
    ```

This cheat sheet covers the essential `kubectl` commands for managing Kubernetes clusters, nodes, pods, and more.

