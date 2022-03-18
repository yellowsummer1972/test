#!/bin/bash

test -d /pump || mkdir /pump
cd /pump || { echo "Error: Cannot change to directory /pump"; exit 1; }
test -f /pump/deliver.sh || cp -rp /pump-init/* /pump/

# start thread
./deliver.sh

