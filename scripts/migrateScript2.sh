#!/bin/bash

# Export ClusterRoleBindings corresponding to selected ClusterRoles

mkdir -p projectconfigs/cluster-role-bindings
for role in $(ls projectconfigs/cluster-roles | sed -e 's/\.yaml$//'); do \
  cmd=(oc get clusterrolebindings  -o jsonpath='{.items[?(@.roleRef.name == ROLE)].metadata.name}'); \
  cmd[4]=${cmd[4]//ROLE/\"$role\"}; \
  for i in $("${cmd[@]}"); do \
  echo "Exporting ClusterRoleBinding: " $i; \
  oc get clusterrolebinding $i -o yaml | \
  yq e 'del(.metadata.creationTimestamp)' - \
  | yq e 'del(.metadata.resourceVersion)' - \
  | yq e 'del(.metadata.selfLink)' - \
  | yq e 'del(.metadata.uid)' -  - > projectconfigs/cluster-role-bindings/$i.yaml; \
done; done

# Export Namespace  Level Resource Quotas
mkdir -p projectconfigs/namespaceconfigs
for ns in $(ls projectconfigs/namespaces | sed -e 's/\.yaml$//'); do 
    for i in $(oc get resourcequotas -n $ns -o jsonpath='{.items[*].metadata.name}'); do
     echo "Exporting resource quotas" $i "for namespace" $ns; \
     mkdir -p projectconfigs/namespaceconfigs/$ns/resource-quotas 
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
        | yq e 'del(.metadata.time)' -  > projectconfigs/namespaceconfigs/$ns/resource-quotas/$i.yaml      
    done; 
done

# Export Project level roles
mkdir -p projectconfigs/namespaceconfigs
for ns in $(ls projectconfigs/namespaces | sed -e 's/\.yaml$//'); do 
    echo "Exporting roles for namespace:" $ns; \
    for i in $(oc get roles -n $ns -o jsonpath='{.items[*].metadata.name}'); do
        mkdir -p projectconfigs/namespaceconfigs/$ns/roles 
        oc get role $i -n $ns -o yaml \
        | yq e 'del(.metadata.creationTimestamp)' - \
        | yq e 'del(.metadata.resourceVersion)' - \
        | yq e 'del(.metadata.selfLink)' - \
        | yq e 'del(.metadata.uid)' - \
        | yq e 'del(.metadata.managedFields)' - \
        | yq e 'del(.metadata.ownerReferences)' - \
        | yq e 'del(.status)' -  > projectconfigs/namespaceconfigs/$ns/roles/$i.yaml
    done;
done

# Export Project level service accounts
mkdir -p projectconfigs/namespaceconfigs
SA_FILTERS="deployer\|builder\|default\|pipeline"
for ns in $(ls projectconfigs/namespaces | sed -e 's/\.yaml$//'); do 
    echo "Exporting service accounts for namespace:" $ns; \
    for i in $(oc get sa -n $ns -o jsonpath='{.items[*].metadata.name}'); do
        if grep -v "$SA_FILTERS" <<< $i ; then 
            mkdir -p projectconfigs/namespaceconfigs/$ns/service-accounts 
            oc get sa $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.uid)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.ownerReferences)' - \
            | yq e 'del(.secrets)' - \
            | yq e 'del(.imagePullSecrets)' - \
            | yq e 'del(.status)' -  > projectconfigs/namespaceconfigs/$ns/service-accounts/$i.yaml
        fi
    done;
done

# Export RoleBindings for Roles and Service Accounts
for ns in $(ls projectconfigs/namespaces | sed -e 's/\.yaml$//'); do 
    for role in $(ls projectconfigs/namespaceconfigs/$ns/roles 2> /dev/null | sed -e 's/\.yaml$//'); do
        cmd=(oc get rolebindings -o jsonpath='{.items[?(@.roleRef.name == ROLE)].metadata.name}' -n NAMESPACE); \
        cmd[4]=${cmd[4]//ROLE/\"$role\"}; \
        cmd[6]=${cmd[6]//NAMESPACE/$ns}; \
        for i in $("${cmd[@]}"); do \
            echo "Exporting Rolebinding Namespace: " $ns "Role: " $role "RB: " $i 
            mkdir -p projectconfigs/namespaceconfigs/$ns/rolebindings
            oc get rolebinding $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.annotations)' - \
            | yq e 'del(.metadata.labels)' - \
            | yq e 'del(.metadata.uid)' - > projectconfigs/namespaceconfigs/$ns/rolebindings/$i.yaml
        done;
    done;
done

for ns in $(ls projectconfigs/namespaces | sed -e 's/\.yaml$//'); do 
    for sa in $(ls projectconfigs/namespaceconfigs/$ns/service-accounts 2> /dev/null | sed -e 's/\.yaml$//'); do
        for i in $(oc get rolebindings -n $ns -o yaml | yq e '.items[] | select(.subjects[].name == "'$sa'") | .metadata.name' -); do
            echo "Exporting Rolebinding Namespace: " $ns "SA: " $sa "RB: " $i
            mkdir -p projectconfigs/namespaceconfigs/$ns/rolebindings
            oc get rolebinding $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.annotations)' - \
            | yq e 'del(.metadata.labels)' - \
            | yq e 'del(.metadata.uid)' - > projectconfigs/namespaceconfigs/$ns/rolebindings/$i.yaml
        done;
    done;
done

# Export RoleBindings for ClusterRoles
for ns in $(ls projectconfigs/namespaces | sed -e 's/\.yaml$//'); do 
    for clusterrole in $(ls projectconfigs/cluster-roles | sed -e 's/\.yaml$//'); do
        for i in $(oc get rolebindings -n $ns -o yaml | yq e '.items[] | select(.roleRef.name == "'$clusterrole'") | .metadata.name' -); do
            echo "Exporting Rolebinding Namespace: " $ns "CR: " $clusterrole "RB: " $i
            mkdir -p projectconfigs/namespaceconfigs/$ns/rolebindings/forclusterroles
            oc get rolebinding $i -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.metadata.annotations)' - \
            | yq e 'del(.metadata.labels)' - \
            | yq e 'del(.metadata.uid)' - > projectconfigs/namespaceconfigs/$ns/rolebindings/forclusterroles/$i.yaml
        done;
    done;
done

# Export EgressNetworkPolicies
mkdir -p projectconfigs/namespaceconfigs
for ns in $(ls projectconfigs/namespaces | sed -e 's/\.yaml$//'); do 
    for i in $(oc get egressnetworkpolicies -n $ns -o jsonpath='{.items[*].metadata.name}'); do
        echo "Exporting Egress Network Policies for namespace:" $ns;
        mkdir -p projectconfigs/namespaceconfigs/$ns/egress-network-policies
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
        | yq e 'del(.metadata.time)' - > projectconfigs/namespaceconfigs/$ns/egress-network-policies/$i.yaml      
    done; 
done





