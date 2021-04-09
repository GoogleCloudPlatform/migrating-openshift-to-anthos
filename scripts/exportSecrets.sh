#!/bin/bash
SECRET_FILTERS="^builder-\|^deployer-\|^default-\|^pipeline-"
oc get secrets -n demo -o jsonpath='{.items[*].metadata.name}' | grep -v $SECRET_FILTERS
for ns in $(ls clusterconfigs/namespaces); do
    echo "Exporting manifests for namespace: " $ns;
    mkdir -p ocp-manifests/namespaces/$ns;
    for secret in $(oc get secrets -n $ns -o jsonpath='{.items[*].metadata.name}' ); do
    if grep -v "$SECRET_FILTERS" <<< $secret ; then
        echo "Exporting Secret: " $secret;
            oc get secret $secret -n $ns -o yaml \
                | yq e 'del(.metadata.creationTimestamp)' - \
                | yq e 'del(.metadata.annotations.*)' - \
                | yq e 'del(.metadata.resourceVersion)' - \
                | yq e 'del(.metadata.selfLink)' - \
                | yq e 'del(.metadata.uid)' - \
                | yq e 'del(.metadata.generateName)' - \
                | yq e 'del(.status)' - \
                > ocp-manifests/namespaces/$ns/$secret-secret.yaml
    fi
    done;
done