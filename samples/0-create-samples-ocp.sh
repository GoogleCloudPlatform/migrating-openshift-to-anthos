#!/bin/zsh
source ./envs.sh
kubectx ${context_src}
./oc apply -f ocp-samples/