#!/bin/bash
rm -f /home/user/flutter/bin/cache/lockfile
echo "Starting Flutter..."
/home/user/flutter/bin/flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0