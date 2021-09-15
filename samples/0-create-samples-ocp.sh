#!/bin/zsh
source ./envs.sh
kubectx ${context_src}
./oc create ns $ns
./oc adm policy add-scc-to-user anyuid system:serviceaccount:${ns}:default
./oc apply -f ocp-samples/ -n $ns
