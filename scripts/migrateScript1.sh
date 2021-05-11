#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Generate Namespaces for Projects
mkdir -p clusterconfigs/namespaces
PROJECT_FILTERS="^openshift-\|^kube-\|^istio-system\|^knative-"
for i in $(oc get projects -o jsonpath='{.items[*].metadata.name}'); do 
if grep -v "$PROJECT_FILTERS" <<< $i ; then 
    echo "Exporting Project: " $i; \
    mkdir -p clusterconfigs/namespaces/$i; \
    oc get project $i -o yaml | \
    yq e '.apiVersion |= "v1"' - \
    | yq e '.kind |= "Namespace"' - \
    | yq e 'del(.metadata.creationTimestamp)' - \
    | yq e 'del(.metadata.annotations.*)' - \
    | yq e 'del(.metadata.managedFields)' - \
    | yq e 'del(.metadata.labels)' - \
    | yq e 'del(.metadata.resourceVersion)' - \
    | yq e 'del(.metadata.selfLink)' - \
    | yq e 'del(.metadata.uid)' - \
    | yq e 'del(.status)' -  \
    > clusterconfigs/namespaces/$i/namespace.yaml
fi
done

# Generate ResourceQuotaTemplates for ClusterResourceQuotas
mkdir -p clusterconfigs/to-review/cluster-resource-quotas
for i in $(oc get clusterresourcequota  -o jsonpath='{.items[*].metadata.name}'); do \
echo "Exporting Cluster Resource Quota:" $i; \
oc get clusterresourcequota $i -o yaml | \
yq e 'del(.metadata.creationTimestamp)' - \
| yq e 'del(.metadata.generation)' - \
| yq e 'del(.metadata.managedFields)' - \
| yq e 'del(.metadata.annotations.*)' - \
| yq e 'del(.metadata.labels)' - \
| yq e 'del(.metadata.resourceVersion)' - \
| yq e 'del(.metadata.selfLink)' - \
| yq e 'del(.metadata.uid)' - > clusterconfigs/to-review/cluster-resource-quotas/$i.original; \
oc get clusterresourcequota $i -o yaml | \
yq e '.apiVersion |= "v1"' - \
| yq e '.kind |= "ResourceQuota"' - \
| yq e 'del(.metadata.creationTimestamp)' - \
| yq e 'del(.metadata.generation)' - \
| yq e 'del(.metadata.managedFields)' - \
| yq e 'del(.metadata.annotations.*)' - \
| yq e 'del(.metadata.labels)' - \
| yq e 'del(.metadata.resourceVersion)' - \
| yq e 'del(.metadata.selfLink)' - \
| yq e 'del(.metadata.uid)' - \
| yq e 'del(.spec.selector)' - \
| yq e '.metadata.namespace |= "CHANGEME"' - > clusterconfigs/to-review/cluster-resource-quotas/$i.yaml
done


# Export Netnamespaces
PROJECT_FILTERS="^openshift-\|^kube-\|^istio-system\|^knative-"
mkdir -p clusterconfigs/to-review/net-namespaces
for i in $(oc get netnamespaces -o jsonpath='{.items[*].metadata.name}'); do 
if grep -v "$PROJECT_FILTERS" <<< $i ; then 
    echo "Exporting NetNamespace: " $i; \
    oc get netnamespaces $i -o yaml \
    | yq e 'del(.metadata.creationTimestamp)' - \
    | yq e 'del(.metadata.resourceVersion)' - \
    | yq e 'del(.metadata.selfLink)' - \
    | yq e 'del(.metadata.uid)' - \
    | yq e 'del(.status)' -  \
    > clusterconfigs/to-review/net-namespaces/$i.yaml
fi
done

# Generate ClusterRoles
mkdir -p clusterconfigs/cluster/cluster-roles
for i in $(oc get clusterroles  -o jsonpath='{.items[*].metadata.name}'); do \
echo "Exporting ClusterRole: " $i
oc get clusterrole $i -o yaml | \
yq e 'del(.metadata.creationTimestamp)' - \
| yq e 'del(.metadata.resourceVersion)' - \
| yq e 'del(.metadata.managedFields)' - \
| yq e 'del(.metadata.selfLink)' - \
| yq e 'del(.metadata.uid)' - > clusterconfigs/cluster/cluster-roles/$i.yaml; \
done


