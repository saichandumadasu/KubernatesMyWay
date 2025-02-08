---
title: ETCD Notes
---

# ETCD Notes

## Overview
ETCD is a distributed reliable key-value store that is simple, secure, and fast.

## Index
- [Installation of ETCD](#installation-of-etcd)
- [Single ETCD Node for Kubernetes](#single-etcd-node-for-kubernetes)
- [Multi ETCD Node for Kubernetes](#multi-etcd-node-for-kubernetes)
- [Securing Communication for ETCD](#securing-communication-for-etcd)
- [Updating ETCD Certificates in Kubernetes](#updating-etcd-certificates-in-kubernetes)
- [Connecting to ETCD Server Using `etcdctl`](#connecting-to-etcd-server-using-etcdctl)
- [Requesting Access to ETCD for New Users](#requesting-access-to-etcd-for-new-users)
- [System Administrator (SA) Access to ETCD](#system-administrator-sa-access-to-etcd)
- [`etcdctl` Cheat Sheet](#etcdctl-cheat-sheet)

## Installation of ETCD

To install ETCD, follow these steps:

1. **Download ETCD**:
    Download the latest version of ETCD from the official GitHub releases page:
    ```sh
    wget https://github.com/etcd-io/etcd/releases/download/v3.5.0/etcd-v3.5.0-linux-amd64.tar.gz
    ```

2. **Extract the tarball**:
    ```sh
    tar xvf etcd-v3.5.0-linux-amd64.tar.gz
    ```

3. **Move the binaries**:
    ```sh
    sudo mv etcd-v3.5.0-linux-amd64/etcd* /usr/local/bin/
    ```

4. **Verify the installation**:
    ```sh
    etcd --version
    ```

5. **Create a systemd service file**:
    Create a file at `/etc/systemd/system/etcd.service` with the following content:
    ```ini
    [Unit]
    Description=etcd key-value store
    Documentation=https://github.com/etcd-io/etcd
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/etcd
    Restart=always
    RestartSec=5
    LimitNOFILE=40000

    [Install]
    WantedBy=multi-user.target
    ```

6. **Start and enable the ETCD service**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl start etcd
    sudo systemctl enable etcd
    ```

7. **Check the ETCD service status**:
    ```sh
    sudo systemctl status etcd
    ```

Following these steps will install and run ETCD on your system.

## Single ETCD Node for Kubernetes

To set up a single ETCD node for Kubernetes, follow these steps:

1. **Install ETCD**:
    Follow the installation steps mentioned above to install ETCD on your system.

2. **Configure ETCD**:
    Edit the `/etc/systemd/system/etcd.service` file to include the following configuration:
    ```ini
    [Unit]
    Description=etcd key-value store
    Documentation=https://github.com/etcd-io/etcd
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/etcd \
      --name etcd0 \
      --data-dir /var/lib/etcd \
      --listen-client-urls http://0.0.0.0:2379 \
      --advertise-client-urls http://0.0.0.0:2379
    Restart=always
    RestartSec=5
    LimitNOFILE=40000

    [Install]
    WantedBy=multi-user.target
    ```

3. **Start and enable the ETCD service**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl start etcd
    sudo systemctl enable etcd
    ```

4. **Verify the ETCD service status**:
    ```sh
    sudo systemctl status etcd
    ```

5. **Start K8s with single etcd node**
    ```sh
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr=192.168.0.0/16 --etcd-servers=http://0.0.0.0:2379
    ```

## Multi ETCD Node for Kubernetes

To set up a multi ETCD node cluster for Kubernetes, follow these steps:

1. **Install ETCD on all nodes**:
    Follow the installation steps mentioned above to install ETCD on each node in your cluster.

2. **Configure ETCD on each node**:
    Edit the `/etc/systemd/system/etcd.service` file on each node to include the following configuration, replacing `<nodeX>` and `<IPX>` with the appropriate values for each node:
    ```ini
    [Unit]
    Description=etcd key-value store
    Documentation=https://github.com/etcd-io/etcd
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/etcd \
      --name <nodeX> \
      --data-dir /var/lib/etcd \
      --listen-peer-urls http://<IPX>:2380 \
      --listen-client-urls http://<IPX>:2379,http://127.0.0.1:2379 \
      --advertise-client-urls http://<IPX>:2379 \
      --initial-advertise-peer-urls http://<IPX>:2380 \
      --initial-cluster <node1>=http://<IP1>:2380,<node2>=http://<IP2>:2380,<node3>=http://<IP3>:2380 \
      --initial-cluster-state new \
      --initial-cluster-token etcd-cluster-1
    Restart=always
    RestartSec=5
    LimitNOFILE=40000

    [Install]
    WantedBy=multi-user.target
    ```

3. **Start and enable the ETCD service on each node**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl start etcd
    sudo systemctl enable etcd
    ```

4. **Verify the ETCD service status on each node**:
    ```sh
    sudo systemctl status etcd
    ```

5. **Start K8s with multi ETCD nodes**:
    ```sh
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr=192.168.0.0/16 --etcd-servers=http://<IP1>:2379,http://<IP2>:2379,http://<IP3>:2379
    ```

Following these steps will set up a single or multi ETCD node cluster for Kubernetes.

## Securing Communication for ETCD

To secure communication for ETCD, you should enable mutual TLS (mTLS) to encrypt data in transit and authenticate clients and peers. Here are the steps to secure ETCD:

1. **Generate Certificates**:
    Generate CA, server, and client certificates. You can use tools like `cfssl` or `openssl` to generate these certificates.

    **Generate Certificates with OPENSSL**:
    Generate CA, server, and client certificates using `openssl`. These certificates are essential for securing communication between ETCD nodes and clients by enabling mutual TLS (mTLS). 

    - **CA Certificate**: The Certificate Authority (CA) certificate is used to sign other certificates. It establishes a chain of trust, ensuring that the server and client certificates are valid and issued by a trusted authority.
    - **Server Certificate**: The server certificate is used by the ETCD server to prove its identity to clients. It ensures that clients are connecting to a legitimate ETCD server.
    - **Client Certificate**: The client certificate is used by ETCD clients to authenticate themselves to the ETCD server. It ensures that only authorized clients can access the ETCD server.

    **Generate CA Certificate**:
    ```sh
    openssl genpkey -algorithm RSA -out ca.key
    openssl req -x509 -new -nodes -key ca.key -subj "/CN=etcd-ca" -days 365 -out ca.crt
    ```

    **Generate Server Certificate**:
    ```sh
    openssl genpkey -algorithm RSA -out server.key
    openssl req -new -key server.key -subj "/CN=etcd-server" -out server.csr
    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
    ```

    **Generate Client Certificate**:
    ```sh
    openssl genpkey -algorithm RSA -out client.key
    openssl req -new -key client.key -subj "/CN=etcd-client" -out client.csr
    openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365
    ```


2. **Configure ETCD to Use Certificates**:
    Edit the `/etc/systemd/system/etcd.service` file to include the following configuration:
    ```ini
    [Unit]
    Description=etcd key-value store
    Documentation=https://github.com/etcd-io/etcd
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/etcd \
      --name etcd0 \
      --data-dir /var/lib/etcd \
      --listen-client-urls https://0.0.0.0:2379 \
      --advertise-client-urls https://0.0.0.0:2379 \
      --cert-file=/path/to/server.crt \
      --key-file=/path/to/server.key \
      --client-cert-auth \
      --trusted-ca-file=/path/to/ca.crt \
      --peer-cert-file=/path/to/peer.crt \
      --peer-key-file=/path/to/peer.key \
      --peer-client-cert-auth \
      --peer-trusted-ca-file=/path/to/ca.crt
    Restart=always
    RestartSec=5
    LimitNOFILE=40000

    [Install]
    WantedBy=multi-user.target
    ```

3. **Restart ETCD Service**:
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl restart etcd
    ```

## Updating ETCD Certificates in Kubernetes

If ETCD is running as a pod in Kubernetes, follow these steps to update the certificates:

1. **Generate New Certificates**:
    Generate new CA, server, and client certificates.

2. **Create Kubernetes Secrets**:
    Create secrets in Kubernetes to store the new certificates:
    ```sh
    kubectl create secret generic etcd-certs --from-file=ca.crt --from-file=server.crt --from-file=server.key --from-file=peer.crt --from-file=peer.key
    ```

3. **Update ETCD Pod Configuration**:
    Edit the ETCD pod configuration to mount the new certificates:
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: etcd
      namespace: kube-system
    spec:
      containers:
      - name: etcd
        image: quay.io/coreos/etcd:v3.5.0
        command:
        - /usr/local/bin/etcd
        - --cert-file=/etc/etcd/certs/server.crt
        - --key-file=/etc/etcd/certs/server.key
        - --client-cert-auth
        - --trusted-ca-file=/etc/etcd/certs/ca.crt
        - --peer-cert-file=/etc/etcd/certs/peer.crt
        - --peer-key-file=/etc/etcd/certs/peer.key
        - --peer-client-cert-auth
        - --peer-trusted-ca-file=/etc/etcd/certs/ca.crt
        volumeMounts:
        - name: etcd-certs
          mountPath: /etc/etcd/certs
          readOnly: true
      volumes:
      - name: etcd-certs
        secret:
          secretName: etcd-certs
    ```

4. **Apply the Updated Configuration**:
    ```sh
    kubectl apply -f etcd-pod.yaml
    ```

By following these steps, you can ensure that communication with ETCD is secure and encrypted, protecting your data and cluster from potential attacks.


## Connecting to ETCD Server Using `etcdctl`

To connect to an ETCD server using `etcdctl`, follow these steps:

1. **Install `etcdctl`**:
    Install `etcdctl` on your machine. You can download it from the official ETCD GitHub releases page.

2. **Set Environment Variables**:
    Set the necessary environment variables to point to the ETCD endpoints and certificates:
    ```sh
    export ETCDCTL_API=3
    export ETCDCTL_ENDPOINTS=https://<etcd-endpoint>:2379
    export ETCDCTL_CACERT=/path/to/ca.crt
    export ETCDCTL_CERT=/path/to/client.crt
    export ETCDCTL_KEY=/path/to/client.key
    ```

3. **Connect to ETCD**:
    Use `etcdctl` to interact with the ETCD server:
    ```sh
    etcdctl get / --prefix --keys-only
    ```

## Requesting Access to ETCD for New Users

If a new user joins the organization and needs access to ETCD, follow these steps:

1. **User Requests Access**:
    The new user should request access by contacting the system administrator (SA) or the relevant team.

2. **Generate Certificates**:
    The SA generates client certificates for the new user "saimadasu" using `openssl`. Follow these steps:

    **On etcd-server:**

    **Generate CA Certificate**:
    ```sh
    openssl genpkey -algorithm RSA -out ca.key
    openssl req -x509 -new -nodes -key ca.key -subj "/CN=etcd-ca" -days 365 -out ca.crt
    ```

    **Generate Client Certificate for saimadasu**:
    ```sh
    openssl genpkey -algorithm RSA -out saimadasu-client.key
    openssl req -new -key saimadasu-client.key -subj "/CN=saimadasu" -out saimadasu-client.csr
    openssl x509 -req -in saimadasu-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out saimadasu-client.crt -days 365
    ```

3. **Distribute Certificates**:
    The SA securely distributes the client certificates (`saimadasu-client.crt`, `saimadasu-client.key`, and `ca.crt`) to the new user.

4. **Set Environment Variables**:
    The new user sets the environment variables to point to the ETCD endpoints and certificates:
    ```sh
    export ETCDCTL_API=3
    export ETCDCTL_ENDPOINTS=https://<etcd-endpoint>:2379
    export ETCDCTL_CACERT=/path/to/ca.crt
    export ETCDCTL_CERT=/path/to/client.crt
    export ETCDCTL_KEY=/path/to/client.key
    ```

5. **Connect to ETCD**:
    The new user uses `etcdctl` to interact with the ETCD server:
    ```sh
    etcdctl get / --prefix --keys-only
    ```

## System Administrator (SA) Access to ETCD

For a system administrator (SA) to access ETCD, follow these steps:

1. **Install `etcdctl`**:
    Install `etcdctl` on the SA's machine.

2. **Set Environment Variables**:
    Set the environment variables to point to the ETCD endpoints and certificates:
    ```sh
    export ETCDCTL_API=3
    export ETCDCTL_ENDPOINTS=https://<etcd-endpoint>:2379
    export ETCDCTL_CACERT=/path/to/ca.crt
    export ETCDCTL_CERT=/path/to/sa-client.crt
    export ETCDCTL_KEY=/path/to/sa-client.key
    ```

3. **Connect to ETCD**:
    Use `etcdctl` to interact with the ETCD server:
    ```sh
    etcdctl get / --prefix --keys-only
    ```

By following these steps, users, admins, and system administrators can securely connect to and interact with the ETCD server using `etcdctl`.




## `etcdctl` Cheat Sheet

### Basic Commands

- **Set a key-value pair**:
    ```sh
    etcdctl put <key> <value>
    ```

- **Get a key-value pair**:
    ```sh
    etcdctl get <key>
    ```

- **Delete a key**:
    ```sh
    etcdctl del <key>
    ```

- **List keys with a prefix**:
    ```sh
    etcdctl get <prefix> --prefix
    ```

### Cluster Health

- **Check cluster health**:
    ```sh
    etcdctl endpoint health
    ```

- **List all endpoints**:
    ```sh
    etcdctl endpoint status --write-out=table
    ```

### Snapshots

- **Save a snapshot**:
    ```sh
    etcdctl snapshot save <filename>
    ```

- **Restore a snapshot**:
    ```sh
    etcdctl snapshot restore <filename> --data-dir <data-dir>
    ```

- **Check snapshot status**:
    ```sh
    etcdctl snapshot status <filename>
    ```

### User Management

- **Add a new user**:
    ```sh
    etcdctl user add <username>
    ```

- **Delete a user**:
    ```sh
    etcdctl user delete <username>
    ```

- **List all users**:
    ```sh
    etcdctl user list
    ```

- **Grant a role to a user**:
    ```sh
    etcdctl user grant-role <username> <role>
    ```

### Role Management

- **Add a new role**:
    ```sh
    etcdctl role add <role>
    ```

- **Delete a role**:
    ```sh
    etcdctl role delete <role>
    ```

- **List all roles**:
    ```sh
    etcdctl role list
    ```

- **Grant a permission to a role**:
    ```sh
    etcdctl role grant-permission <role> <readwrite|read|write> <key> [endkey]
    ```

### Authentication

- **Enable authentication**:
    ```sh
    etcdctl auth enable
    ```

- **Disable authentication**:
    ```sh
    etcdctl auth disable
    ```

### Maintenance

- **Defragment the store**:
    ```sh
    etcdctl defrag
    ```

- **Compact the store**:
    ```sh
    etcdctl compact <revision>
    ```

### Environment Variables

- **Set ETCD endpoints**:
    ```sh
    export ETCDCTL_ENDPOINTS=https://<etcd-endpoint>:2379
    ```

- **Set ETCD API version**:
    ```sh
    export ETCDCTL_API=3
    ```

- **Set ETCD certificates**:
    ```sh
    export ETCDCTL_CACERT=/path/to/ca.crt
    export ETCDCTL_CERT=/path/to/client.crt
    export ETCDCTL_KEY=/path/to/client.key
    ```

This cheat sheet covers the essential `etcdctl` commands for managing ETCD clusters, users, roles, snapshots, and more.