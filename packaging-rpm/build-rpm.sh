#!/usr/bin/env bash

set -e

# get locations and names
scriptdir="$(pwd)"
repodir="$scriptdir/../"
rpmbuilddir="$scriptdir/rpmbuild"
specname="metaeffekt-inventory-script.spec"
packagename="metaeffekt-inventory-script"

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



