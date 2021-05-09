#!/bin/zsh
source envs.sh
kubectx "${context_dst}"
my_status=""
while true; do
  if [[ "${my_status}" == "Completed" ]]; then
#!/bin/zsh
    echo "Backup is ready in kubernetes cluster"
    break;
  else
    my_status=$(velero backup get | grep "${backup_name}" | awk '{print $2}')
    echo "status=${my_status}: Wait for backup to be completed..."
    sleep 10
  fi
done

velero restore create ${restore_name} --from-backup ${backup_name}
my_status=""
while true; do
  if [[ "${my_status}" == "Completed" ]]; then
#!/bin/zsh
    echo "Restore is ready in kubernetes cluster"
    break;
  else
    my_status=$(velero restore get | grep "${restore_name}" | awk '{print $3}')
    echo "status=${my_status}: Wait for restore to be completed..."
    sleep 10
  fi
done
kubectl apply -f kubernetes-manifests/namespaces/$ns/
