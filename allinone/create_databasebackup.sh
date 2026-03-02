#!/bin/bash

rm -f .dumpbackupdir
# Check postgres version
if grep -q "postgres:18" ../**/docker-compose.yml && ! grep -q "postgres:14" ../**/docker-compose.yml; then
    echo "PostgreSQL is already updated to 18. No update is required."
    exit 0
fi

DUMPBACKUPDIR=postgres_dump_"$(date +%Y-%m-%d"_"%H-%M-%S)"
DBBACKUPDIR=postgres_backup_"$(date +%Y-%m-%d"_"%H-%M-%S)"
mkdir -p  "$DBBACKUPDIR" "$DUMPBACKUPDIR"
. .env

for i in 3d-service hub-auth hub-ui hypha-backend-dictionary hypha-bff hypha-core hypha-dashboard hypha-files hypha-gateway hypha-resources hypha-tasks hypha-ui hypha-workflow ; do
  echo "Down $i"
  docker compose down "$i" || true
done

for i in hypha-files-db hypha-core-db hypha-dashboard-db hypha-tags-db hub-auth-db hypha-resources-db 3d-service-db hypha-workflow-db hypha-bff-db hypha-tasks-db; do
  echo "Start database $i"
  docker compose up -d $i || true
  sleep 5
done

# Check if service running
dump_db() {
  local service=$1
  local user=$2
  local output=$3
  if ! docker compose ps --services --filter "status=running" | grep -qx "$service"; then
    echo "Error: service '$service' Is not running."
    exit 1
  fi
  if ! docker compose exec -T "$service" pg_dumpall -U "$user" > "$output"; then
    echo "Error: $service' dump is not ready."
    exit 1
  fi
  echo "$service dump is ready -> $output"
}

dump_db hypha-files-db ${HYPHA_FILES_MANAGER_DB_USERNAME} $DUMPBACKUPDIR/hypha-files-db.sql
dump_db hypha-core-db  ${HYPHA_CORE_DB_USERNAME} $DUMPBACKUPDIR/hypha-core-db.sql
dump_db hypha-dashboard-db ${HYPHA_DASHBOARD_DB_USERNAME} $DUMPBACKUPDIR/hypha-dashboard-db.sql
dump_db hypha-tags-db ${HYPHA_TAGS_DB_USERNAME} $DUMPBACKUPDIR/hypha-tags-db.sql
dump_db hub-auth-db ${HUB_AUTH_DB_USERNAME} $DUMPBACKUPDIR/hypha-auth-db.sql
dump_db hypha-resources-db ${HYPHA_RESOURCE_MANAGER_DB_USERNAME} $DUMPBACKUPDIR/hypha-resources-db.sql
dump_db hypha-workflow-db ${HYPHA_WORKFLOW_DB_USERNAME} $DUMPBACKUPDIR/hypha-workflow-db.sql
dump_db hypha-bff-db ${HYPHA_BFF_DB_USERNAME} $DUMPBACKUPDIR/hypha-bff-db.sql
dump_db hypha-tasks-db ${HYPHA_TASK_MANAGER_DB_USERNAME} $DUMPBACKUPDIR/hypha-tasks-db.sql
dump_db 3d-service-db ${HYPHA_3D_SERVICE_DB_USERNAME} $DUMPBACKUPDIR/3d-service-db.sql


for i in hypha-files-db hypha-core-db hypha-dashboard-db hypha-tags-db hub-auth-db hypha-resources-db 3d-service-db hypha-workflow-db hypha-bff-db hypha-tasks-db; do
  echo "Down database $i"
  docker compose down $i || true
done

# $(for i in pg_3d_service pg_auth pg_bff pg_core pg_dashboard pg_fm pg_rm pg_tags pg_tm pg_workflow; do mv $i $DBBACKUPDIR/$i ; done)

# Check backups
for d in pg_*; do
  if [ -d "$d" ]; then
    mv "$d" "$DBBACKUPDIR/"
  fi
done

remaining=$(find . -maxdepth 1 -type d -name "pg_*" -print)
if [ -n "$remaining" ]; then
  echo "Error: Not moved : $remaining"
  exit 1
fi

backup_ok=false
for d in "$DBBACKUPDIR"/pg_*; do
  if [ -d "$d" ] && [ -n "$(ls -A "$d")" ]; then
    backup_ok=true
    break
  fi
done
if [ "$backup_ok" = false ]; then
  echo "Error: empty backup catalog in $DBBACKUPDIR"
  exit 1
fi
echo "DUMPBACKUPDIR=$DUMPBACKUPDIR" > .dumpbackupdir
echo "Backup is done"
