#!/bin/zsh
source envs.sh

kubectx ${context_src}
velero install \
    --provider gcp \
    --plugins velero/velero-plugin-for-gcp:v1.1.0 \
    --bucket $BUCKET \
    --use-restic \
    --secret-file credentials-velero

./oc -n velero patch ds/restic --type json -p '[{"op":"add","path":"/spec/template/spec/containers/0/securityContext","value": { "privileged": true}}]'
./oc -n velero patch ds/restic --type json -p '[{"op":"replace","path":"/spec/template/spec/volumes/0/hostPath","value": { "path": "/var/lib/kubelet/pods"}}]'

kubectx ${context_dst}
velero install \
    --provider gcp \
    --plugins velero/velero-plugin-for-gcp:v1.1.0 \
    --bucket $BUCKET \
    --use-restic \
    --secret-file credentials-velero
kubectx ${context_src}
