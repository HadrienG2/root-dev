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
cmake -GNinja -DCMAKE_CXX_STANDARD=17 -Dasimage=OFF -Dclad=OFF -Ddavix=OFF     \
              -Dfail-on-missing=ON -Dfftw3=OFF -Dfitsio=OFF -Dgdml=OFF         \
              -Dgfal=OFF -Dhttp=OFF -Dmlp=OFF -Dmysql=OFF -Dopengl=OFF         \
              -Doracle=OFF -Dpgsql=OFF -Dpythia6=OFF -Dpythia8=OFF             \
              -Dpython=OFF -Droofit=OFF -Droot7=ON -Droottest=OFF              \
              -Dspectrum=OFF -Dsqlite=OFF -Dssl=OFF -Dtesting=ON -Dthreads=ON  \
              -Dtmva=OFF -Dvdt=OFF -Dwebgui=OFF -Dx11=OFF -Dxml=OFF            \
              -Dxrootd=OFF                                                     \
      /mnt/root

# Build ROOT
ninja

# Run the tests
#
# FIXME: For now, this will fail. Figure out the right exclude list to make it
#        work. Also, add to this list tests which are not run automatically by
#        ctest like the RHist tests.
#
ctest -j8

# Install ROOT
ninja install
