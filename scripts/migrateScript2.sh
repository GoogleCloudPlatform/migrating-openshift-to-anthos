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

# Export ClusterRoleBindings corresponding to selected ClusterRoles

mkdir -p clusterconfigs/cluster/cluster-role-bindings
for role in $(ls clusterconfigs/cluster/cluster-roles | sed -e 's/\.yaml$//'); do \
  cmd=(oc get clusterrolebindings  -o jsonpath='{.items[?(@.roleRef.name == ROLE)].metadata.name}'); \
  cmd[4]=${cmd[4]//ROLE/\"$role\"}; \
  for i in $("${cmd[@]}"); do \
  echo "Exporting ClusterRoleBinding: " $i; \
  oc get clusterrolebinding $i -o yaml | \
  yq e 'del(.metadata.creationTimestamp)' - \
  | yq e 'del(.metadata.resourceVersion)' - \
  | yq e 'del(.metadata.selfLink)' - \
  | yq e 'del(.metadata.managedFields)' - \
  | yq e 'del(.metadata.uid)' -  - > clusterconfigs/cluster/cluster-role-bindings/$i.yaml; \
done; done

# Export Namespace  Level Resource Quotas
for ns in $(ls clusterconfigs/namespaces); do 
    for i in $(oc get resourcequotas -n $ns -o jsonpath='{.items[*].metadata.name}'); do
     echo "Exporting resource quotas" $i "for namespace" $ns; \
     mkdir -p clusterconfigs/namespaces/$ns
     oc get resourcequota $i -n $ns -o yaml \
        | yq e 'del(.metadata.creationTimestamp)' - \
        | yq e 'del(.metadata.resourceVersion)' - \
        | yq e 'del(.metadata.selfLink)' - \
        | yq e 'del(.metadata.uid)' - \
        | yq e 'del(.status)' -  \
        | yq e 'del(.metadata.managedFields)' - \
        | yq e 'del(.metadata.annotations)' - \
        | yq e 'del(.metadata.manager)' - \
        | yq e 'del(.metadata.operation)' - \
        | yq e 'del(.metadata.time)' -  > clusterconfigs/namespaces/$ns/$i-quota.yaml      
    done; 
done

# Export Namespace level roles
for ns in $(ls clusterconfigs/namespaces); do 
    echo "Exporting roles for namespace:" $ns; \
    for i in $(oc get roles -n $ns -o jsonpath='{.items[*].metadata.name}'); do
        oc get role $i -n $ns -o yaml \
        | yq e 'del(.metadata.creationTimestamp)' - \
        | yq e 'del(.metadata.resourceVersion)' - \
        | yq e 'del(.metadata.selfLink)' - \
        | yq e 'del(.metadata.uid)' - \
        | yq e 'del(.metadata.managedFields)' - \
        | yq e 'del(.metadata.ownerReferences)' - \
        | yq e 'del(.status)' -  > clusterconfigs/namespaces/$ns/$i-role.yaml
    done;
done

# Export Project level service accounts
SA_FILTERS="deployer\|builder\|default\|pipeline"
for ns in $(ls clusterconfigs/namespaces); do 
    echo "Exporting service accounts for namespace:" $ns; \
    for i in $(oc get sa -n $ns -o jsonpath='{.items[*].metadata.name}'); do
        if grep -v "$SA_FILTERS" <<< $i ; then 
            oc get sa $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.uid)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.ownerReferences)' - \
            | yq e 'del(.secrets)' - \
            | yq e 'del(.imagePullSecrets)' - \
            | yq e 'del(.status)' -  > clusterconfigs/namespaces/$ns/$i-sa.yaml
        fi
    done;
done

# Export RoleBindings for Roles and Service Accounts
for ns in $(ls clusterconfigs/namespaces); do 
    for role in $(ls clusterconfigs/namespaces/$ns/*-role.yaml 2> /dev/null | xargs -n 1 basename 2> /dev/null | sed -e 's/-role\.yaml$//'); do
        cmd=(oc get rolebindings -o jsonpath='{.items[?(@.roleRef.name == ROLE)].metadata.name}' -n NAMESPACE); \
        cmd[4]=${cmd[4]//ROLE/\"$role\"}; \
        cmd[6]=${cmd[6]//NAMESPACE/$ns}; \
        for i in $("${cmd[@]}"); do \
            echo "Exporting Rolebinding Namespace: " $ns "Role: " $role "RB: " $i 
            oc get rolebinding $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.annotations)' - \
            | yq e 'del(.metadata.ownerReferences)' - \
            | yq e 'del(.metadata.labels)' - \
            | yq e 'del(.metadata.uid)' - > clusterconfigs/namespaces/$ns/$i-rolebinding.yaml
        done;
    done;
done

for ns in $(ls clusterconfigs/namespaces); do 
    for sa in $(ls clusterconfigs/namespaces/$ns/*-sa.yaml 2> /dev/null | xargs -n 1 basename 2> /dev/null | sed -e 's/-sa\.yaml$//'); do
        for i in $(oc get rolebindings -n $ns -o yaml | yq e '.items[] | select(.subjects[].name == "'$sa'") | .metadata.name' -); do
            echo "Exporting Rolebinding Namespace: " $ns "SA: " $sa "RB: " $i
            oc get rolebinding $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.annotations)' - \
            | yq e 'del(.metadata.ownerReferences)' - \
            | yq e 'del(.metadata.labels)' - \
            | yq e 'del(.metadata.uid)' - > clusterconfigs/namespaces/$ns/$i-rolebinding.yaml
        done;
    done;
done

# Export RoleBindings for ClusterRoles
for ns in $(ls clusterconfigs/namespaces); do 
    for clusterrole in $(ls clusterconfigs/cluster/cluster-roles | sed -e 's/\.yaml$//'); do
        for i in $(oc get rolebindings -n $ns -o yaml | yq e '.items[] | select(.roleRef.name == "'$clusterrole'") | .metadata.name' -); do
            echo "Exporting Rolebinding Namespace: " $ns "CR: " $clusterrole "RB: " $i
            mkdir -p clusterconfigs/to-review/namespace-clusterrole-bindings/namespaces/$ns
            oc get rolebinding $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.annotations)' - \
            | yq e 'del(.metadata.ownerReferences)' - \
            | yq e 'del(.metadata.labels)' - \
            | yq e 'del(.metadata.uid)' - > clusterconfigs/to-review/namespace-clusterrole-bindings/namespaces/$ns/$i-rolebinding.yaml
        done;
    done;
done

# Export EgressNetworkPolicies
for ns in $(ls clusterconfigs/namespaces); do 
    for i in $(oc get egressnetworkpolicies -n $ns -o jsonpath='{.items[*].metadata.name}'); do
        echo "Exporting Egress Network Policies for namespace:" $ns;
        mkdir -p clusterconfigs/to-review/egress-network-policies/namespaces/$ns
        oc get egressnetworkpolicy $i -n $ns -o yaml \
        | yq e 'del(.metadata.creationTimestamp)' - \
        | yq e 'del(.metadata.resourceVersion)' - \
        | yq e 'del(.metadata.selfLink)' - \
        | yq e 'del(.metadata.uid)' - \
        | yq e 'del(.status)' -  \
        | yq e 'del(.metadata.managedFields)' - \
        | yq e 'del(.metadata.annotations)' - \
        | yq e 'del(.metadata.manager)' - \
        | yq e 'del(.metadata.operation)' - \
        | yq e 'del(.metadata.generation)' - \
        | yq e 'del(.metadata.time)' - > clusterconfigs/to-review/egress-network-policies/namespaces/$ns/$i-egress-network-policy.yaml      
    done; 
done





