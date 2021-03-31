# Migration from OpenShift to Anthos/GKE Cluster
[DRAFT]

This guide provides scripts and tools to migration cluster configurations and workloads from an OpenShift Cluster to Anthos or GKE Cluster.

## Migrating OpenShift SCCs to ACM Constraints
WIP

## Migrating OpenShift Project Configurations

This section addresses migrating openshift projects, cluster level configurations and project level configurations to the target cluster. This process is semi-automated because certain decisions require choices to be made by the person who is migrating. Also the procedure allows you to either migration an application at a time or all the workloads running on a cluster.

### Prerequisites

* Linux bash shell: These scripts have been tested on google cloud console
* oc - openshift client. Login to the OpenShift cluster from which you are migrating.
* yq - yaml parsing tool

### Export Project Configurations

* [Export Projects to Namespaces](1.ExportingProjects.md)
* [Export ClusterResourceQuotas to K8S ResourceQuotas](2.ClusterResourceQuota.md)
* [Export ClusterRoles and ClusterRoleBindings](3.ClusterRolesAndRoleBindings.md)
* [Capture NetNamespaces data](4.NetNameSpaces.md)
* [Export Project Level Resource Quotas](5.ResourceQuotas.md)
* [Export Project Level Service Accounts, Roles and RoleBindings](6.RolesAndRoleBindings.md)
* [Capture Egress Network Policies data](7.EgressNetworkPolicies.md)
* Apply NetworkPolicies based on EgressNetworkPolicies and NetNamespaces (WIP)

**All the steps in the above documentation links should be read.** Once you read and understand, you can run the following scripts rather than individually copy pasting the scripts. These scripts will generate a folder named `projectconfigs` with the manifests that can be applied to the target GKE Cluster.

* Run script#1 that exports namespaces, clusterresourcequotas and cluster roles.

```
chmod +x ./scripts/migrateScript1.sh
./scripts/migrateScript1.sh
```
* Review the namespace manifests generated in the `projectconfigs/namespaces` and remove the ones that don't need to be migrated
* Review ClusterRoles in the `projectconfigs/cluster-roles` folder and remove the ones that don't need to be migrated
* Review NetNamespaces in the `projectconfigs/net-namespaces` folder and remove the ones that are not required.
* Run script#2 to export ClusterRoleBindings and namespace Level configurations.

```
chmod +x ./scripts/migrateScript2.sh
./scripts/migrateScript2.sh
```
* Review the Service Accounts, Roles and RoleBindings that are generated in the individual namespace folders and remove the ones that don't need to be migrated to the target cluster
* Review ResourceQuotas and copy the templates to create namespace specific quotas in the namespace folders

## Migrating Workloads to Target GKE Cluster
WIP

## Migrate Persistent Data
WIP
