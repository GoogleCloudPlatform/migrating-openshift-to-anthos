#!/bin/zsh
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET=velero.shawnk8s.com
export context_src="admin"
export context_dst="gke_anthos-demo-280104_asia-east1-a_cluster-target"
export backup_name="select-backup"
export restore_name="select-restore"
export ns="default"
export pvc_name="pvc-frontend"
export mylabel="service=frontend"