####################### CONTAINER-SIDE ROOT BUILD SCRIPT #######################
# This script is meant to run inside of the container. If you are trying to    #
# build the container, you're probably looking for the "build.sh" script.      #
################################################################################

# Force bash to catch more errors
set -euo pipefail
IFS=$'\n\t'

# Go to the build directory
cd /root/ROOT-build

# Configure a minimal ROOT build, just what I need for RHist development and
# nothing more. This will save disk space and build time
#
# FIXME: It seems ninja is currently broken, falling back to GNU Make.
#
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_STANDARD=14  -Dasimage=OFF \
      -Dclad=OFF -Ddavix=OFF -Ddev=ON -Dfail-on-missing=ON -Dfftw3=OFF         \
      -Dfitsio=OFF -Dgdml=OFF -Dgfal=OFF -Dhttp=OFF -Dmlp=OFF -Dmysql=OFF      \
      -Dopengl=OFF -Doracle=OFF -Dpgsql=OFF -Dpythia6=OFF -Dpythia8=OFF        \
      -Dpyroot=OFF -Dpyroot_experimental=OFF -Droofit=OFF -Droot7=ON           \
      -Droottest=OFF -Dspectrum=OFF -Dsqlite=OFF -Dssl=OFF -Dtesting=ON        \
      -Dthreads=ON -Dtmva=OFF -Dvdt=OFF -Dwebgui=OFF -Dx11=OFF -Dxml=OFF       \
      -Dxrootd=OFF                                                             \
      /mnt/root

# Build ROOT
make -j8

# Run the tests
#
# - Some tests are disabled because they rely on disabled ROOT components and
#   thus couldn't succeed without enabling those (unwanted) components.
# - The tutorial-tree-bill test is disabled because it tries to write into our
#   read-only ROOT source tree, which is not okay.
# - The gtest-tree-treeplayer-test-treeprocessormt test is disabled because it
#   segfaults for no clear reason.
#
# TODO: Report tests which are enabled when they shouldn't be as bugs.
# TODO: Also trim out tests which succeed but do things they shouldn't do such
#       as downloading huge files.
# TODO: Roll out a RelWithDebInfo build to figure out why the treeprocessormt
#       test is segfaulting, hopefully that should give a better stack trace.
#
ctest -j8 -E "(pyunittests|SQlite|gdml|^tutorial-tree-bill$|^gtest-tree-treeplayer-test-treeprocessormt$)"

# Install ROOT
make install
