#!/bin/zsh
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET=openshift-migrate
export context_src="admin"
export context_dst="gke_ocp-tester-0002_asia-east1-a_gke-0001"
export ns="demo"
export pvc_name="pvc-frontend"
export mylabel="service=frontend"
index=$(date "+%Y%m%d%H%M%S")
export backup_name="select-backup"
export restore_name="select-restore"
