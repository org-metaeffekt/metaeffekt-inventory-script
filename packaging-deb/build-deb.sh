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
scriptDir="$(pwd)"
repoDir="$scriptDir/../"
tmpDir="${scriptDir}/tmp-package-build"

packageName="metaeffekt-inventory-script"

srcVerForDeb="$(git describe --tags --abbrev=16)"
srcVerForDeb="$(printf '%s' "$srcVerForDeb" | sed 's/^v//1;s/-/./g')"

if [ ! -f "$scriptDir/build-deb.sh" ]; then
  echo "error: current directory does not contain the build script."
  echo "error: ensure you cd into the script's directory."
fi

mkdir "${tmpDir}"
mkdir "${tmpDir}/${packageName}"

# create source archive directly from the git repo
(cd "${repoDir}" && git archive --format=tar.gz --output="${tmpDir}/${packageName}_${srcVerForDeb}.orig.tar.gz" HEAD)

# untar sources into subdirectory
tar -xf "${tmpDir}/${packageName}_${srcVerForDeb}.orig.tar.gz" -C "${tmpDir}/${packageName}"

# copy debian directory into subdirectory
cp -r "${scriptDir}/debian" "${tmpDir}/${packageName}/"

# hack the changelog to display a valid version and date
currentDate="$(date -R)"
sed "s/_#_VERSIONHERE_#_/${srcVerForDeb}/g;s/_#_DATEHERE_#_/${currentDate}/g" "${scriptDir}/debian/changelog" > "${tmpDir}/${packageName}/debian/changelog"

# build the package
(cd "${tmpDir}/${packageName}" && dpkg-buildpackage -us -uc -b)
