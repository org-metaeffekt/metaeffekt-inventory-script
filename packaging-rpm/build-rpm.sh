#!/usr/bin/env bash

#
# Copyright 2021 metaeffekt GmbH.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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



