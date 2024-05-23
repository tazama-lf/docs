<!-- SPDX-License-Identifier: Apache-2.0 -->

# Kubernetes - Managing Stateful Workloads And One-off Jobs

StatefulSet is the workload API object used to manage **stateful applications**. Manages the deployment and scaling of a set of [Pods](https://kubernetes.io/docs/concepts/workloads/pods/), *and provides guarantees about the ordering and uniqueness* of these Pods.

If you want to use **storage volumes** to provide *persistence* for your workload, you can use a StatefulSet as part of the solution. Although individual Pods in a StatefulSet are susceptible to failure, the persistent Pod identifiers make it easier to match existing volumes to the new Pods that replace any that have failed.

## StatefulSet example applications

- MongoDB
- MySql with Galera replication
- Cassandra
- Zoo Keeper

# Challenges Scaling Stateful Workloads

![](../../images/1_igoCkmlQP-MdaOSayEdbLw.png)

The StatefulSet is a special type of controller that makes it easy to run clustered workloads in Kubernetes. A clustered workload typically may have one or more masters and multiple slaves. Most of the databases are designed to run in a clustered mode to deliver high availability and fault tolerance.

To make it easy to run stateful clustered workloads in Kubernetes, StatefulSets were introduced. The Pods that belong to a StatefulSet are guaranteed to have stable, unique identifiers. They follow a predictable naming convention and also support ordered, graceful deployment and scaling.

Each Pod participating in a StatefulSet has a corresponding **Persistent Volume Claim** (PVC) that follows a similar naming convention. When a Pod gets terminated and is rescheduled on a different Node, the Kubernetes controller will ensure that the Pod is associated with the same PVC which will guarantee that the state is intact.

Since each Pod in a StatefulSet gets a dedicated PVC and PV, there is no hard and fast rule to use shared storage. But it is expected that the StatefulSet is backed by a fast, reliable, durable storage layer such as an SSD-based block storage device. After ensuring that the writes are fully committed to the disk, regular backups and snapshots can be taken from the block storage devices.

***Storage Choices:** SSDs, Block Storage Devices such as* [*Amazon EBS*](https://aws.amazon.com/ebs/)*,* [*Azure Disks*](https://azure.microsoft.com/en-us/services/storage/disks/)*,* [*GCE PD*](https://cloud.google.com/persistent-disk)

***Typical Workloads:*** [*Apache ZooKeeper*](https://zookeeper.apache.org/)*,* [*Apache Kafka*](https://kafka.apache.org/)*,* [*Percona Server for MySQL*](https://www.percona.com/software/mysql-database/percona-server)*,* [*PostgreSQL Automatic Failover*](https://clusterlabs.github.io/PAF/)*, and* [*JupyterHub*](https://jupyter.org/hub)

## Kubernetes Persistent Storage Concepts

![](../../images/media-20180208.png)

There are three primary concepts you should understand as you start working with Kubernetes persistent storage:

**PersistentVolume (PV)**  
An API volume object that represents a storage location that lives in your Kubernetes cluster. A PV is implemented as a Volume plugin—it abstracts the details of the storage implementation (such as NFS or iSCSI communication), from the storage consumer. The main feature of a PV is that it has an independent life cycle, and it continues to live when the pods accessing it have shut down.

**PersistentVolumeClaim (PVC)**  
This is a request sent by a Kubernetes node for storage. The claim can include specific storage parameters required by the application—for example an amount of storage, or a specific type of access (read/write, read-only, etc.).

Kubernetes looks for a PV that meets the criteria defined in the user’s PVC, and if there is one, it matches claim to PV. This is called **binding**. You can also configure the cluster to dynamically provision a PV for a claim.

**StorageClass**  
The StorageClass object allows cluster administrators to define PVs with different properties, like performance, size or access parameters. It lets you expose persistent storage to users while abstracting the details of storage implementation. There are many predefined StorageClasses in Kubernetes (see the following section), or you can create your own.

| **Cloud Storage and Virtualization** | **Proprietary Storage Platforms** | **Physical Drives / Storage Protocols** |
| --- | --- | --- |
| GCEPersistentDisk | Flocker | NFS |
| AWSElasticBlockStore | RBD (Ceph Block Device) | iSCSI |
| AzureFile | Cinder (OpenStack block storage) | FC (Fibre Channel) |
| AzureDisk | Glusterfs |     |
| VsphereVolume | Flexvolume |     |
|     | Quobyte Volumes |     |
|     | Portworx Volumes |     |
|     | ScaleIO Volumes |     |
|     | StorageOS |     |

# Managing the Persistent Volumes

1. OpenEBS builds on Kubernetes to enable Stateful applications to easily access Dynamic Local PVs or Replicated PVs. By using the Container Attached Storage pattern users report lower costs, easier management, and more control for their teams. [https://openebs.io/](https://openebs.io/)

***Storage Choices:*** [*NetApp Trident*](https://github.com/NetApp/trident)*,* [*Maya Data*](https://mayadata.io/)*,* [*Portworx*](http://www.portworx.com/)*,* [*Reduxio*](https://www.reduxio.com/)*,* [*Red Hat OpenShift Container Storage*](https://www.redhat.com/en/technologies/cloud-computing/openshift-container-storage)*,* [*Robin Systems*](https://robin.io/)*,* [*Rook*](https://rook.io/)*,* [*StorageOS*](https://storageos.com/)

***Typical Workloads:** Any workload that expects durability and persistence*

A YAML config is enough to create a Persistent Volumes or Statefulsets but to manage the persistent volumes using by Statefulsets needs tools such as OpenEBS.

## Kubernetes One-off jobs

A Job is a special kind of controller that creates and manages a set of pods that are going to do some finite work. Like Deployment, a Job will recreate its Pods in case of a node failure. It also has `parallelism` property to specify how many pods should be doing the job and how many of them should succeed (`completions`) until the whole jobs becomes “finished”.

Here’s an example of a job that finds all the prime numbers between 1 and 70:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: primes
spec:
  containers:
  - name: primes
    image: ubuntu
    command: \["bash"\]
    args: \["-c",  "current=0; max=70; echo 1; echo 2; for((i=3;i<=max;)); do for((j=i-1;j>=2;)); do if \[  \`expr $i % $j\` -ne 0 \] ; then current=1; else current=0; break; fi; j=\`expr $j - 1\`; done; if \[ $current -eq 1 \] ; then echo $i; fi; i=\`expr $i + 1\`; done"\]
  restartPolicy: Never

```

We can also parallelize the application:

```yaml
spec:
  completions: 8
  parallelism: 4
  template:
    ....
```

Which allows us do interesting things, like picking a topic from Kafka, database, or from anywhere else.

## Introducing, HELM HOOKS

Helm provides a *hook* mechanism to allow chart developers to intervene at certain points in a release's life cycle. For example, you can use hooks to:

- Load a ConfigMap or Secret during install before any other charts are loaded.
- Execute a Job to back up a database before installing a new chart, and then execute a second job after the upgrade in order to restore data.
- Run a Job before deleting a release to gracefully take a service out of rotation before removing it.

There’s multiple hooks provided by Helm:

| Annotation Value | Description |
| --- | --- |
| `pre-install` | Executes after templates are rendered, but before any resources are created in Kubernetes |
| `post-install` | Executes after all resources are loaded into Kubernetes |
| pre-delete | Executes on a deletion request before any resources are deleted from Kubernetes |
| post-delete | Executes on a deletion request after all of the release's resources have been deleted |
| pre-upgrade | Executes on an upgrade request after templates are rendered, but before any resources are updated |
| post-upgrade | Executes on an upgrade request after all resources have been upgraded |
| pre-rollback | Executes on a rollback request after templates are rendered, but before any resources are rolled back |
| post-rollback | Executes on a rollback request after all resources have been modified |
| test | Executes when the Helm test subcommand is invoked |

Here’s how a pre-install hook would look for the previous job described:

![](../../images/Hook.png)

```yaml
apiVersion: v1
kind: Job
metadata:
  name: "{{.Release.Name}}"
  labels:
    app.kubernetes.io/managed-by: {{.Release.Service | quote }}
    app.kubernetes.io/instance: {{.Release.Name | quote }}
    helm.sh/chart: "{{.Chart.Name}}-{{.Chart.Version}}"
  annotations:
    # This is what defines this resource as a hook. Without this line, the
    # job is considered part of the release.
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: "{{.Release.Name}}"
      labels:
        app.kubernetes.io/managed-by: {{.Release.Service | quote }}
        app.kubernetes.io/instance: {{.Release.Name | quote }}
        helm.sh/chart: "{{.Chart.Name}}-{{.Chart.Version}}"
    spec:
      restartPolicy: Never
      containers:
      - name: pre-install-job
        image: "ubuntu"
        command: \["bash"\]
        args: \["-c",  "current=0; max=70; echo 1; echo 2; for((i=3;i<=max;)); do for((j=i-1;j>=2;)); do if \[  \`expr $i % $j\` -ne 0 \] ; then current=1; else current=0; break; fi; j=\`expr $j - 1\`; done; if \[ $current -eq 1 \] ; then echo $i; fi; i=\`expr $i + 1\`; done"\]
```

Helm Hooks allows us to extend when we operate certain jobs, and if such features are not needed, a simple YAML can still be developed since we’ll use Helmfile to deploy our application.

It is up to the developer to decide what method to use in his given situation.

**Related**

[Kubernetes Cluster Access](../01- Knowledge-Articles/Kubernetes-Cluster-Access.md)

[Kubernetes - Load balancing with gRPC](../../architecture-and-design/linkerd/load-balancing-with-grpc.md)

**External Links**

[https://medium.com/@marko.luksa/graceful-scaledown-of-stateful-apps-in-kubernetes-2205fc556ba9](https://medium.com/@marko.luksa/graceful-scaledown-of-stateful-apps-in-kubernetes-2205fc556ba9)

[https://mayadata.io/usecases/statefulsets](https://mayadata.io/usecases/statefulsets)

[https://thenewstack.io/different-approaches-for-building-stateful-kubernetes-applications/](https://thenewstack.io/different-approaches-for-building-stateful-kubernetes-applications/)

[https://www.youtube.com/watch?v=-Va5FWnY2iI](https://www.youtube.com/watch?v=-Va5FWnY2iI)

[https://portworx.com/tutorial-kubernetes-persistent-volumes/](https://portworx.com/tutorial-kubernetes-persistent-volumes/)

[https://codeblog.dotsandbrackets.com/one-off-kubernetes-jobs/](https://codeblog.dotsandbrackets.com/one-off-kubernetes-jobs/)

[https://stackoverflow.com/questions/55458237/deploying-a-kubernetes-job-via-helm](https://stackoverflow.com/questions/55458237/deploying-a-kubernetes-job-via-helm)

[https://helm.sh/docs/topics/charts\_hooks/](https://helm.sh/docs/topics/charts_hooks/)
