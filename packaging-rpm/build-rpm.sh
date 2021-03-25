#!/usr/bin/env bash

set -e

# get locations and names
scriptdir="$(pwd)"
repodir="$scriptdir/../"
rpmbuilddir="$scriptdir/rpmbuild"
specname="metaeffekt-inventory-script.spec"
packagename="metaeffekt-inventory-script"

# check the current workdir. this is done to make sure the git archive and
# git describe commands (in spec file) run correctly.
# alternatively override the variables at the top of the script.
if [ ! -f "$scriptdir/build-rpm.sh" ]; then
  echo "error: current directory does not contain the build script."
  echo "error: ensure you cd into the script's directory."
fi

# create rpmbuild directories
mkdir -v "$scriptdir/rpmbuild"
mkdir -v "$scriptdir/rpmbuild/BUILD"
mkdir -v "$scriptdir/rpmbuild/RPMS"
mkdir -v "$scriptdir/rpmbuild/SOURCES"
mkdir -v "$scriptdir/rpmbuild/SPECS"
mkdir -v "$scriptdir/rpmbuild/SRPMS"

# get sources and spec
(cd "$repodir" ; git archive --format=tar.gz --output="$rpmbuilddir/SOURCES/$packagename-src.tar.gz" HEAD)
cp -v "$scriptdir/$specname" "$rpmbuilddir/SPECS/"

# build
rpmbuild -v --define "_topdir $scriptdir/rpmbuild" -bb "$scriptdir/rpmbuild/SPECS/$specname"



