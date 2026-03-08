#!/bin/sh

set -eu

frame=0
delay="${SLEEP_SECONDS:-2}"

while true; do
  printf '\033[2J\033[H'

  case $((frame % 5)) in
    0)
      cat <<'EOF'
  /\_/\\
 ( o.o )   Gato supervisor del cluster
  > ^ <
EOF
      ;;
    1)
      cat <<'EOF'
   .-.
  (o o)   Búho revisando logs a las 3 AM
  | O \
   \   \
    `~~~'
EOF
      ;;
    2)
      cat <<'EOF'
      __
     <(o )___   Pato desplegando en producción
      ( ._> /
       `---'
EOF
      ;;
    3)
      cat <<'EOF'
  __
 (oo)____   Vaquita observando el pipeline
 (__)    )\\
    ||--|| *
EOF
      ;;
    4)
      cat <<'EOF'
   _
 _( )__    Cohete listo para otro rollout
(_   _ _)
  / / \\
EOF
      ;;
  esac

  frame=$((frame + 1))
  sleep "$delay"
done