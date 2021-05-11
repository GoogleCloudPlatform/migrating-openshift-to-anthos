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
