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
