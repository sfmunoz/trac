#!/bin/bash

set -e -o pipefail

[ "$USER_UID" = "" ] && USER_UID="1000"
[ "$USER_GID" = "" ] && USER_GID="1000"
[ "$REALM" = "" ] && REALM="trac-server"
[ "$TRAC_UMASK" = "" ] && TRAC_UMASK="077"

export REALM

python3 <<__EOF
from hashlib import md5
from os import environ, getenv
realm = environ["REALM"]
i = 0
with open("passwd","w") as fp:
    while True:
        i += 1
        v = getenv(f"TRAC_USER_PASS_{i}")
        if v is None:
            break
        up = v.split(":")
        if len(up) != 2:
            break
        u,p = up
        raw = f"{u}:{realm}:{p}"
        h = md5(raw.encode("utf-8")).hexdigest()
        fp.write(f"{u}:{realm}:{h}\n")
__EOF

set -x

groupadd -g $USER_GID trac
useradd -u $USER_UID -g $USER_GID -m -d /home/trac trac
chown trac:trac passwd
chmod 600 passwd

exec tracd \
  -p 8080 \
  --user trac \
  --group trac \
  --umask $TRAC_UMASK \
  -s \
  -a "trac-env,./passwd,${REALM}" \
  /trac-env
