# Recipe for a ROOT development environment

These days I'm working on [ROOT](https://root.cern/) histogramming, so I need to
be able to quickly build and test a development version of it. Given how
invasive a ROOT install gets, it's best to test it in an isolated environment.

I'd normally use [Spack](https://spack.io/) for this purpose, but it's not
exactly up to date with latest versions of ROOT and I do not currently have
enough time to update its build recipes. So for now, I'm building a dedicated
Docker image the old way.

The automated build is performed via `./build.sh`, but as it's quite specific to
my machine it will almost surely fail on yours without modification. You'll
want to study how it works and adapt it to your needs instead.
