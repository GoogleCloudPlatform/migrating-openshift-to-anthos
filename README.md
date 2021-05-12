# Migration from OpenShift to Anthos/GKE Cluster

This respository provides scripts and tools to migration cluster configurations and workloads from an OpenShift Cluster to Anthos or GKE Cluster. It assumes that the users have prior working experience with Kubernetes and OpenShift. This material focuses on actual migration using scripts and tooling. We assume that you already have an OpenShift cluster with applications running on it to migrate to the target cluster. 

In case you using this material to prepare or try hands-on all by yourself, you don't have an openshift cluster with applications running this [demo application setup](./0.DemoClusterandApplication.md) may be helpful.

## Scope and Assumptions

### In Scope
* Migration targets a single OpenShift source cluster to a single GKE/Anthos target cluster at a time
* Considers running application workloads such as deployments, services, and ingress mechanisms and related artifacts such as config maps, images etc.

### Out of Scope
* Migrating builds and CICD are currenty out of scope. Build and CICD mechanisms have to be set up independently to point to the target cluster and registry.
* Migrating applications that may span multiple clusters is out of scope
* Migrating multiple environments such as a development cluster, test cluster and production cluster as a group is out of scope. Each cluster migration should be handled independently.



## Migrating OpenShift Project Configurations

This section addresses migrating openshift projects, cluster level configurations and project level configurations to the target cluster. This process is semi-automated because certain decisions require choices to be made by the person who is migrating. Also the procedure allows you to either migration an application at a time or all the workloads running on a cluster.

### Prerequisites

* Linux bash shell: These scripts have been tested on an Ubuntu linux box

* `oc` - [openshift client](https://docs.openshift.com/container-platform/4.7/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli). Login to the OpenShift cluster from which you are migrating. These scripts expect that you have [**cluster-wide read** access](./0.DemoClusterandApplication.md#create-a-cluster-viewer-role) to the openshift cluster so that you are able to export cluster configuration

* `yq` - [yaml processing tool](https://github.com/mikefarah/yq#install)
* Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) and login with your Google credentials via SDK
* Install kubernetes clients such as kubectl, kubectx
* A target GKE cluster is set up and you have access to deploy applications to that cluster

### Export Project Configurations

* [Export Projects to Namespaces](1.ExportingProjects.md)
* [Export ClusterResourceQuotas to K8S ResourceQuotas](2.ClusterResourceQuota.md)
* [Export ClusterRoles and ClusterRoleBindings](3.ClusterRolesAndRoleBindings.md)
* [Capture NetNamespaces data](4.NetNameSpaces.md)
* [Export Project Level Resource Quotas](5.ResourceQuotas.md)
* [Export Project Level Service Accounts, Roles and RoleBindings](6.RolesAndRoleBindings.md)
* [Capture Egress Network Policies data](7.EgressNetworkPolicies.md)
* Apply NetworkPolicies based on EgressNetworkPolicies (WIP)

**All the steps in the above documentation links should be read.** Once you read and understand, you can run the following scripts rather than individually copy pasting the scripts. These scripts will generate a folder named `clusterconfigs` with the manifests that can be applied to the target GKE Cluster. The folder structure follows [ACM repo layout](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/concepts/repo). You can create a git repo and apply this using [ConfigSync](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/overview) to an Anthos Cluster.

* Run script#1 that exports namespaces, clusterresourcequotas and cluster roles.

```
chmod +x ./scripts/migrateScript1.sh
./scripts/migrateScript1.sh
```
* Review the namespace manifests generated in the `clusterconfigs/namespaces` and remove the ones that don't need to be migrated
* Review ClusterRoles in the `clusterconfigs/cluster/cluster-roles` folder and remove the ones that don't need to be migrated
* Run script#2 to export ClusterRoleBindings and namespace Level configurations.

```
chmod +x ./scripts/migrateScript2.sh
./scripts/migrateScript2.sh
```
* Review the Service Accounts, Roles and RoleBindings that are generated in the individual namespace folders and remove the ones that don't need to be migrated to the target cluster
* Review ClusterResourceQuotas in `clusterconfigs/to-review/cluster-resource-quotas` and copy the templates to create namespace specific quotas in the namespace folders with namespace based allocations
* Review NetNamespaces in the `clusterconfigs/to-review/net-namespaces` folder. **Handling TBD**

## Apply Configurations with Anthos Config Manager (ACM)

* Stand up a Anthos cluster if you don't already have one and [install Anthos Config Management Components](https://cloud.google.com/anthos-config-management/docs/how-to/installing)
* [Install nomos](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/nomos-command)
* Initialize `clusterconfigs` repo  
```
cd clusterconfigs
nomos init --force
```
* Create a git repository to host the structure. Initialize the `clusterconfig` folder as a git repo and push the to git repo.
* [Install ConfigSync](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/installing). Configure the git repo as the Sync Repo
* Login to the Anthos Cluster and verify that the manifests from the repository are applied.

## Migrating OpenShift SCCs to ACM Constraints

Security Policies will be applied on the Anthos Cluster using ACM Policy Controller.  [Constraints](https://cloud.google.com/anthos-config-management/docs/how-to/creating-constraints) can be created using [constraint template library](https://cloud.google.com/anthos-config-management/docs/how-to/creating-constraints#constraint-template-library) that google provides or you can write your own constraint templates.

* [Install Policy Controller](https://cloud.google.com/anthos-config-management/docs/how-to/installing-policy-controller). Exclude the following namespaces from policy controller (refer Exempt namespaces). Review the list, you may have more to exclude depending on which namespaces you don't want to apply policies to.

```
kube-system
kube-public
gke-connect
gke-system
config-management-system
gatekeeper-system
istio-system
cnrm-system
knative-serving
monitoring-system
```
* After you set up Policy Controller with the above exceptions you need to add to each of the exempted namespaces the following label to actually exclude them from constraints application:
```
admission.gatekeeper.sh/ignore=true
```
If you don’t do that, system Pods and, consequently, your entire cluster, can be affected by restrictive policies.

* Verify that the constraint policy templates are installed by running `kubectl get constrainttemplates`

* [Set up ACM Policy Controller Constraints on the cluster](8.SetupConstraints.md)


## Migrating Workloads to Target GKE Cluster

* [Export Application Manifests](./9.ExportApplicationManifests.md) such as deployment configurations, deployments, services, routes, persistent volumes, config maps from each namespace on the OpenShift cluster. 

    These can be exported individually on a per namespace basis or you can run the following script to export them for all the selected namespaces in `clusterconfigs/namespaces` folder. The source manifests are copied into `ocp-manifests/namespaces` folder in order to convert them in the next step.

    ```
    ./scripts/exportApplicationManifests.sh
    ```
    **CAUTION** While secrets can also be copied from the OpenShift cluster, since this is sensitive data you may want to use discretion on copying secrets vs applying them directly on the target cluster. So, DON'T RUN THE COMMAND BELOW until you are ABSOLUTELY SURE that you want to copy secrets from the source cluster.

    ```
    ./scripts/exportSecrets.sh
    ```

* [Migrate Images from OpenShift Internal Registry](./10.TransferApplicationImages.md), if required. This is needed only if the application images are stored in OpenShift Internal Registry. 

* [Migration Application Workloads](./11.MigrateApplications.md) to the target cluster. This uses [Shifter tool](https://github.com/garybowers/shifter) that converts OpenShift manifests to kubernetes manifests. While all the above steps are handled for the entire cluster, we recommend migrating application workloads one namespace at a time. 



## Migrate Persistent Data
[Migration Application Workloads with Persistent Data](./12.MigrateApplications_with_PersistentData.md) could assist users to migrate Openshift workloads and persistent data to GKE/Anthos cluster. This flow follows the flow from [Migration Application Workloads](./11.MigrateApplications.md) but add an opensource tool, [Velero](https://velero.io), to include persistent data migration. To conduct this migration, an object storage (e.g. Google Cloud Storage(GCS)) is required to keep the persistent data before restoring to the target cluster.

Along with the instruction, we also provide [a demo sample](./samples/0-create-samples-ocp.sh) along with [5 easy steps](./samples) to assist readers to hands-on this migration flow on GCP before handling own workloads. Users need to prepare (1) a GKE cluster, (2) a GCS bucket, and (3) your existing openshift cluster in advance to input those data into [environmental variable file](./samples/envs.sh). When running the script, please change directory into samples folder.
