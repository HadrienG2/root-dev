#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Build the base system
docker build --pull --tag root-dev-base -f Dockerfile.base .

# Run the actual ROOT build
#
# This step cannot be made part of the Dockerfile above because it requires a
# bind mount of the ROOT development source tree, and the Docker Build
# Reproducibilty Strike Force won't let you do such things.
#
docker run -v ~/Software/root:/mnt/root,ro                                     \
           --name root-dev-cont                                                \
           root-dev-base                                                       \
           bash /root/ROOT-build/root-build-worker.sh

# If the ROOT build succeeded, we can now commit the root-dev image from the
# root-dev-cont container that we just made...
docker commit root-dev-cont root-dev

# ...and then we don't need that container anymore and can drop it
docker container rm root-dev-cont