#!/usr/bin/env bash
set -euo pipefail

mkdir -p /history
touch /history/.bash_history /history/.irb_history /history/.pry_history || true

ln -sf /history/.bash_history /root/.bash_history
ln -sf /history/.irb_history  /root/.irb_history
ln -sf /history/.pry_history  /root/.pry_history

rm -f /app/tmp/pids/server.pid || true

if [ -f /app/package.json ] && [ "${SKIP_JS_INSTALL:-0}" != "1" ]; then
  echo "→ Instalando dependências JS..."
  yarn install --frozen-lockfile || yarn install
fi

# if [ "${SKIP_DB_PREPARE:-0}" != "1" ]; then
#   echo "→ Preparando banco..."
#   if bundle exec rails -T | grep -q "db:prepare"; then
#     bundle exec rails db:prepare
#   else
#     bundle exec rails db:create || true
#     bundle exec rails db:migrate
#   fi
# fi

exec "$@"
