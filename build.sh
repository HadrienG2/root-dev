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

# Build ROOT in both C++14 and C++17 mode
#
# We need both because ROOT 7 development is currently capped to C++14 only
# while hists-mt currently requires at least C++17 to build.
#
for ROOT_CXX_STD in 14 17; do
    # Run the actual ROOT build
    #
    # This step cannot be made part of the Dockerfile above because it requires
    # a bind mount of the ROOT development source tree, and the Docker Build
    # Reproducibilty Strike Force won't let us do such an unclean thing.
    #
    docker run -v ~/Bureau/Programmation/root:/mnt/root:ro                     \
               --name root-dev-cont                                            \
               root-dev-base                                                   \
               bash /root/ROOT-build/root-build-worker.sh $ROOT_CXX_STD

    # If the ROOT build succeeded, we can now commit the root-dev image from the
    # root-dev-cont container that we just made...
    docker commit --change "CMD bash" root-dev-cont root-dev:cxx${ROOT_CXX_STD}

    # ...and then we don't need that container anymore and can drop it
    docker container rm root-dev-cont
done

# Alright, we're done
echo "*** ROOT development containers were built successfully ***"

# NOTE: The output "root-dev" images preserve the CMake build cache, so that
#       you can quickly re-run the build by just firing up a container in
#       root-dev with the same bind mount as above, go to /root/ROOT-build,
#       and run "ninja" and whatever else you'd like in there.
