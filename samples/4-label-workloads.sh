#!/bin/zsh
source envs.sh

./oc label pvc ${pvc_name} ${mylabel}
my_pv=$(./oc get pv | grep ${pvc_name} | awk '{print $1}')
./oc label pv ${my_pv} ${mylabel}

velero backup create select-backup --selector ${mylabel} --default-volumes-to-restic
