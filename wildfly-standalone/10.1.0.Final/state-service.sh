#!/bin/bash

set -e

echo "WORKING" > /state
while true ; do nc -l -p 8333 -c 'cat /state' ; done