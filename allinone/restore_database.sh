#!/bin/bash

. .env

if [[ -f .dumpbackupdir ]]; then
    source .dumpbackupdir
else
    echo ".dumpbackupdir not found. Do not update"
    exit 0
fi

expected_dirs="pg_fm pg_core pg_dashboard pg_tags pg_auth pg_rm pg_3d_service pg_workflow pg_bff pg_tm"
for dir in $expected_dirs; do
  if [ ! -d "$dir" ]; then
    echo "Error: folder $dir is not exist"
    exit 1
  elif [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    echo "Error: folder $dir is not empty"
    exit 1
  fi
done

for i in hypha-files-db hypha-core-db hypha-dashboard-db hypha-tags-db hub-auth-db hypha-resources-db 3d-service-db hypha-workflow-db hypha-bff-db hypha-tasks-db; do
  echo "Start  $i"
  docker compose up -d $i || true
  sleep 5
done

# Checks for restore
restore_db() {
  local service=$1
  local user=$2
  local dbname=$3
  local dump_file=$4

  if ! docker compose ps --services --filter "status=running" | grep -qx "$service"; then
    echo "ERROR: Service '$service' is not running. Cannot restore."
    exit 1
  fi

  if [ ! -f "$dump_file" ]; then
    echo "ERROR: Dump file '$dump_file' not found."
    exit 1
  fi

  echo "Restoring $service from $dump_file ..."
  if ! docker compose exec -T "$service" psql -U "$user" -d "$dbname" < "$dump_file"; then
    echo "ERROR: Failed to restore database for service '$service'."
    exit 1
  fi
  echo "Restore of $service completed."
}

#   restore_db "$service" "$user" "postgres" "$dump_file"
restore_db hypha-files-db ${HYPHA_FILES_MANAGER_DB_USERNAME} fmdb $DUMPBACKUPDIR/hypha-files-db.sql
restore_db hypha-core-db ${HYPHA_CORE_DB_USERNAME} coredb $DUMPBACKUPDIR/hypha-core-db.sql
restore_db hypha-dashboard-db ${HYPHA_DASHBOARD_DB_USERNAME} myc_hypha_dashboard $DUMPBACKUPDIR/hypha-dashboard-db.sql
restore_db hypha-tags-db ${HYPHA_TAGS_DB_USERNAME} myc_hypha_tags $DUMPBACKUPDIR/hypha-tags-db.sql
restore_db hub-auth-db ${HUB_AUTH_DB_USERNAME} authdb $DUMPBACKUPDIR/hypha-auth-db.sql
restore_db hypha-resources-db ${HYPHA_RESOURCE_MANAGER_DB_USERNAME} myc_hypha_rm $DUMPBACKUPDIR/hypha-resources-db.sql
restore_db hypha-workflow-db ${HYPHA_WORKFLOW_DB_USERNAME} myc_hypha_workflow $DUMPBACKUPDIR/hypha-workflow-db.sql
restore_db hypha-bff-db ${HYPHA_BFF_DB_USERNAME} myc_hypha_bff $DUMPBACKUPDIR/hypha-bff-db.sql
restore_db hypha-tasks-db ${HYPHA_TASK_MANAGER_DB_USERNAME} myc_hypha_tm $DUMPBACKUPDIR/hypha-tasks-db.sql
restore_db 3d-service-db ${HYPHA_3D_SERVICE_DB_USERNAME} 3dservicedb $DUMPBACKUPDIR/3d-service-db.sql

docker compose up -d
