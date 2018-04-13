#!/bin/bash
set -e

echo "WORKING" > /state
while true ; do netcat -l -p 8333 -c 'cat /state' ; done
