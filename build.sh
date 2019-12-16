#!/bin/bash

##################### RHIST DEVELOPMENT CONTAINER BUILDER ######################
# Run this script to regenerate the "root-dev" docker image based on the       #
# latest developments of ~/Software/root. When short on time, you can also     #
# study it to run only the part that you're interested in.                     #
################################################################################

# Force bash to catch more errors
set -euo pipefail
IFS=$'\n\t'

# Build the base system
#
# You can speed up this part by running this command without the --pull
# parameter when you're not interested in updating the container's underlying
# openSUSE Tumbleweed operating system image.
#
docker build --pull --tag root-dev-base -f Dockerfile.base .

# Run the actual ROOT build
#
# This step cannot be made part of the Dockerfile above because it requires a
# bind mount of the ROOT development source tree, and the Docker Build
# Reproducibilty Strike Force won't let us do such an unclean thing.
#
docker run -v ~/Software/root:/mnt/root:ro                                     \
           --name root-dev-cont                                                \
           root-dev-base                                                       \
           bash /root/ROOT-build/root-build-worker.sh

# If the ROOT build succeeded, we can now commit the root-dev image from the
# root-dev-cont container that we just made...
docker commit --change "CMD bash" root-dev-cont root-dev

# ...and then we don't need that container anymore and can drop it
docker container rm root-dev-cont

# NOTE: The output "root-dev" image preserves the CMake build cache, so that
#       you can quickly re-run the build by just firing up a container in
#       root-dev with the same bind mount as above, go to /root/ROOT-build,
#       and run "ninja" and whatever alse you'd like in there.
