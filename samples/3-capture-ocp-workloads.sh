#!/bin/zsh
source envs.sh

# Capture workload
for dc in $(./oc get dc -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
  echo "Exporting DeploymentConfigs: " $dc;
  ./oc get dc $dc -n $ns -o yaml \
    | yq e 'del(.metadata.creationTimestamp)' - \
    | yq e 'del(.metadata.annotations.*)' - \
    | yq e 'del(.metadata.labels.template*)' - \
    | yq e 'del(.metadata.labels.xpaas)' - \
    | yq e 'del(.metadata.resourceVersion)' - \
    | yq e 'del(.metadata.selfLink)' - \
    | yq e 'del(.metadata.uid)' - \
    | yq e 'del(.metadata.generation)' - \
    | yq e 'del(.metadata.managedFields)' - \
    | yq e 'del(.status)' -  \
    > ocp-manifests/namespaces/$ns/$dc-dc.yaml;
done

for route in $(./oc get route -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
  echo "Exporting Route: " $route;
  ./oc get route $route -n $ns -o yaml \
    | yq e 'del(.metadata.creationTimestamp)' - \
    | yq e 'del(.metadata.annotations.*)' - \
    | yq e 'del(.metadata.labels.template*)' - \
    | yq e 'del(.metadata.labels.xpaas)' - \
    | yq e 'del(.metadata.resourceVersion)' - \
    | yq e 'del(.metadata.selfLink)' - \
    | yq e 'del(.metadata.managedFields)' - \
    | yq e 'del(.metadata.uid)' - \
    | yq e 'del(.status)' - \
    > ocp-manifests/namespaces/$ns/$route-route.yaml
done

    #imagestreams
    for is in $(./oc get is -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting ImageStreams: " $is;
        ./oc get is $is -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.annotations.*)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.generation)' - \
            | yq e 'del(.metadata.uid)' - \
            > ocp-manifests/namespaces/$ns/$is-is.yaml
    done;

    #services
    for service in $(./oc get service -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting service: " $service;
        ./oc get svc $service -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.annotations.*)' - \
            | yq e 'del(.metadata.labels.template*)' - \
            | yq e 'del(.metadata.labels.xpaas)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.uid)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.status)' -  \
            | yq e 'del(.spec.clusterIP)' -  \
            | yq e 'del(.spec.clusterIPs)' -  \
            > ocp-manifests/namespaces/$ns/$service-service.yaml
    done;
./shifter convert -f ./ocp-manifests/namespaces/$ns -t yaml -o ./kubernetes-manifests/namespaces/$ns
