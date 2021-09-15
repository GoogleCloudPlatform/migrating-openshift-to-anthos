#!/bin/zsh
source envs.sh
kubectx ${context_src}
./oc label pvc ${pvc_name} ${mylabel} -n $ns
my_pv=$(./oc get pv -n $ns | grep ${pvc_name} | awk '{print $1}')
./oc label pv ${my_pv} ${mylabel} -n $ns

velero backup create ${backup_name} --selector ${mylabel} --default-volumes-to-restic
