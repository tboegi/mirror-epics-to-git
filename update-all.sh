#!/bin/sh
for f in copy*.sh; do
  echo =========================
  echo PWD=$PWD f=$f
  ./$f || {
    echo "error, see above"
    echo >&2 "error PWD=$PWD f=$f"
  }
done
echo ====== EOF ===============
