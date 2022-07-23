#!/bin/sh

ISUCON_DB_HOST=${ISUCON_DB_HOST:-127.0.0.1}
ISUCON_DB_PORT=${ISUCON_DB_PORT:-3306}
ISUCON_DB_USER=${ISUCON_DB_USER:-root}
ISUCON_DB_PASSWORD=${ISUCON_DB_PASSWORD:-root}
ISUCON_DB_NAME=${ISUCON_DB_NAME:-isuports}

for tenant_id in $(ls ../tenant_db/*.db | sed -e "s/^\.\.\/tenant_db\///" -e "s/\.db$//")
do
  echo "tenant $tenant_id setup"
  cat <<EOF > "tenant_init_$tenant_id.sql"
DROP DATABASE IF EXISTS \`tenant_$tenant_id\`;
CREATE DATABASE \`tenant_$tenant_id\`;
USE \`tenant_$tenant_id\`;
EOF
  ./sqlite3-to-sql "../tenant_db/$tenant_id.db" > "tenant_data_tmp_$tenant_id.sql"
  sed -e ':a;N;$!ba;s/;\nINSERT INTO competition VALUES/,/g' -e ':a;N;$!ba;s/;\nINSERT INTO player VALUES/,/g' -e ':a;N;$!ba;s/;\nINSERT INTO player_score VALUES/,/g' "tenant_data_tmp$tenant_id.sql" > "tenant_data_$tenant_id.sql"
  cat "tenant_init_$tenant_id.sql" tenant/10_schema.sql "tenant_data_$tenant_id.sql" > "../tenant_db/tenant_$tenant_id.sql"
  rm "tenant_init_$tenant_id.sql" "tenant_data_$tenant_id.sql" "tenant_data_tmp_$tenant_id.sql"
done
