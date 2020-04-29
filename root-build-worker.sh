####################### CONTAINER-SIDE ROOT BUILD SCRIPT #######################
# This script is meant to run inside of the container. If you are trying to    #
# build the container, you're probably looking for the "build.sh" script.      #
#                                                                              #
# The script takes one argument, which is the ROOT build's C++ standard mode.  #
################################################################################

# Force bash to catch more errors
set -euo pipefail
IFS=$'\n\t'

# Decode CLI args
ROOT_CXX_STD=$1

# Go to the build directory
cd /root/ROOT-build

# Configure a minimal ROOT build, just what I need for RHist development and
# nothing more. This will save disk space and build time
#
# FIXME: It seems ninja is currently broken, falling back to GNU Make.
#
# FIXME: Disabling "dev" mode, which implies -Werror, until ROOT master is
#        warnings-free on GCC 10.
#
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_STANDARD=${ROOT_CXX_STD}   \
      -Dasimage=OFF -Dclad=OFF -Ddavix=OFF -Ddev=OFF -Dfail-on-missing=ON      \
      -Dfftw3=OFF -Dfitsio=OFF -Dgdml=OFF -Dgfal=OFF -Dhttp=OFF -Dmlp=OFF      \
      -Dmysql=OFF -Dopengl=OFF -Doracle=OFF -Dpgsql=OFF -Dpythia6=OFF          \
      -Dpythia8=OFF -Dpyroot=OFF -Dpyroot_experimental=OFF -Droofit=OFF        \
      -Droot7=ON -Droottest=OFF -Dspectrum=OFF -Dsqlite=OFF -Dssl=OFF          \
      -Dtesting=ON -Dthreads=ON -Dtmva=OFF -Dvdt=OFF -Dwebgui=OFF -Dx11=OFF    \
      -Dxml=OFF -Dxrootd=OFF                                                   \
      /mnt/root

# Build ROOT
make -j8

# Run the tests
#
# - Some tests are disabled because they rely on disabled ROOT components and
#   thus couldn't succeed without enabling those (unwanted) components.
# - The tutorial-tree-bill test is disabled because it tries to write into our
#   read-only ROOT source tree, which is not okay.
#
# TODO: Report tests which are enabled when they shouldn't be as bugs.
# TODO: Also trim out tests which succeed but do things they shouldn't do such
#       as downloading huge files.
#
ctest -j8 -E "(gdml|^tutorial-tree-bill$)"

# Install ROOT
make install

# Activate the ROOT enviroment
#
# Must disable the protection against use of unbound shell variables as the
# thisroot script is not compatible with that.
#
set +u
source /usr/local/bin/thisroot.sh
set -u

# Test that hists-mt still works with this ROOT version
#
# FIXME: Make it work in C++14 mode
#
cd /mnt/hists-mt
if [ ${ROOT_CXX_STD} -eq 17 ]; then
    make clean
    make test -j8
fi
