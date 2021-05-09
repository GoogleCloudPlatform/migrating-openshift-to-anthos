#!/bin/zsh
source envs.sh

kubectx ${context_dst}
kubectl delete -f kubernetes-manifests/namespaces/${ns}
kubectl delete pvc -l service=frontend
rm -r kubernetes-manifests/namespaces/${ns}/*
velero restore delete ${restore_name}

kubectx ${context_src}
velero backup delete ${backup_name}
./oc label pvc -l service=frontend service-
./oc label pv -l service=frontend service-
rm -r ocp-manifests/namespaces/${ns}/*