#!/bin/bash
for ns in $(ls clusterconfigs/namespaces); do
    echo "Exporting manifests for namespace: " $ns;
    mkdir -p ocp-manifests/namespaces/$ns;
    
    #deploymentconfigs
    for dc in $(oc get dc -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting DeploymentConfigs: " $dc;
        oc get dc $dc -n $ns -o yaml \
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
    done;

    #deployments
    for deployment in $(oc get deployments -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting Deployments: " $deployment;
        oc get deployment $deployment -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.annotations.*)' - \
            | yq e 'del(.metadata.labels.template*)' - \
            | yq e 'del(.metadata.labels.xpaas)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.uid)' - \
            | yq e 'del(.metadata.generation)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.status)' - \
            > ocp-manifests/namespaces/$ns/$deployment-deployment.yaml
    done;

    #imagestreams
    for is in $(oc get is -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting ImageStreams: " $is;
        oc get is $is -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.annotations.*)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.generation)' - \
            | yq e 'del(.metadata.uid)' - \
            > ocp-manifests/namespaces/$ns/$is-is.yaml
    done;

    #services
    for service in $(oc get service -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting service: " $service;
        oc get svc $service -n $ns -o yaml \
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

    #routes
    for route in $(oc get route -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting Route: " $route;
        oc get route $route -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.annotations.*)' - \
            | yq e 'del(.metadata.labels.template*)' - \
            | yq e 'del(.metadata.labels.xpaas)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.uid)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.status)' - \
            > ocp-manifests/namespaces/$ns/$route-route.yaml

    done;

    #configmaps
    for cm in $(oc get cm -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting ConfigMap: " $cm;
        oc get cm $cm -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.annotations.*)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.uid)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.status)' - \
            > ocp-manifests/namespaces/$ns/$cm-cm.yaml

    done;

    #persistentvolumeclaims
    for pvc in $(oc get pvc -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
        echo "Exporting PVC: " $pvc;
        oc get pvc $pvc -n $ns -o yaml \
            | yq e 'del(.metadata.creationTimestamp)' - \
            | yq e 'del(.metadata.annotations.*)' - \
            | yq e 'del(.metadata.resourceVersion)' - \
            | yq e 'del(.metadata.selfLink)' - \
            | yq e 'del(.metadata.uid)' - \
            | yq e 'del(.metadata.managedFields)' - \
            | yq e 'del(.status)' - \
            > ocp-manifests/namespaces/$ns/$pvc-pvc.yaml

    done;
done