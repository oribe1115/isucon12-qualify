#!/bin/sh

set -ex
cd `dirname $0`

ISUCON_DB_HOST=${ISUCON_DB_HOST:-127.0.0.1}
ISUCON_DB_PORT=${ISUCON_DB_PORT:-3306}
ISUCON_DB_USER=root
ISUCON_DB_PASSWORD=root
ISUCON_DB_NAME=${ISUCON_DB_NAME:-isuports}

# MySQLを初期化
mysql -u"$ISUCON_DB_USER" \
		-p"$ISUCON_DB_PASSWORD" \
		--host "$ISUCON_DB_HOST" \
		--port "$ISUCON_DB_PORT" \
		"$ISUCON_DB_NAME" < init.sql

for tenant_id in $(ls ../../initial_data/*.db | sed -e "s/^\.\.\/\.\.\/initial_data\///" -e "s/\.db$//")
do
  echo "tenant $tenant_id setup"
  cat <<EOF > "tenant_init_$tenant_id.sql"
USE \`tenant_$tenant_id\`;
DELETE FROM competition WHERE created_at >= '1654041600';
DELETE FROM player WHERE created_at >= '1654041600';
DELETE FROM player_score WHERE created_at >= '1654041600';
EOF
  mysql -u"$ISUCON_DB_USER" \
  		-p"$ISUCON_DB_PASSWORD" \
  		--host "$ISUCON_DB_HOST" \
  		--port "$ISUCON_DB_PORT" < "tenant_init_$tenant_id.sql"
  rm "tenant_init_$tenant_id.sql"
done

# SQLiteのデータベースを初期化
# rm -f ../tenant_db/*.db
# cp -r ../../initial_data/*.db ../tenant_db/
