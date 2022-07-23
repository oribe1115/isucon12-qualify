#!/bin/sh

ISUCON_DB_HOST=${ISUCON_DB_HOST:-127.0.0.1}
ISUCON_DB_PORT=${ISUCON_DB_PORT:-3306}
ISUCON_DB_USER=${ISUCON_DB_USER:-root}
ISUCON_DB_PASSWORD=${ISUCON_DB_PASSWORD:-root}
ISUCON_DB_NAME=${ISUCON_DB_NAME:-isuports}

for tenant_id in $(ls ../../initial_data/*.db | sed -e "s/^\.\.\/\.\.\/initial_data\///" -e "s/\.db$//")
do
  echo "tenant $tenant_id setup"
  mysql -u"$ISUCON_DB_USER" \
    		-p"$ISUCON_DB_PASSWORD" \
    		--host "$ISUCON_DB_HOST" \
    		--port "$ISUCON_DB_PORT" < "../tenant_db/tenant_$tenant_id.sql"
done