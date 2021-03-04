#!/bin/sh

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


# rather fail earlier than later
set -e

# define the directory to store files in
# this used to be /analysis once.
METAEFFEKT_INV_WDIR="/var/tmp/inventory"

echo "Executing rhel-extractor.sh"

# create folder structure in analysis folder (assuming sufficient permissions)
mkdir -p /analysis/package-meta

# examine distributions metadata
uname -a > $METAEFFEKT_INV_WDIR/uname.txt
cat /etc/issue > $METAEFFEKT_INV_WDIR/issue.txt
cat /etc/rhel-release > $METAEFFEKT_INV_WDIR/release.txt

# list packages
rpm -qa --qf '| %{NAME} | %{VERSION} | %{LICENSE} |\n' | sort > $METAEFFEKT_INV_WDIR/packages_rpm.txt

# list packages names (no version included)
rpm -qa --qf '%{NAME}\n' | sort > $METAEFFEKT_INV_WDIR/packages_rpm-name-only.txt

# query package metadata and covered files
packagenames=`cat $METAEFFEKT_INV_WDIR/packages_rpm-name-only.txt`
for package in $packagenames
do
  rpm -qi $package > $METAEFFEKT_INV_WDIR/package-meta/${package}_rpm.txt
done

# if docker is installed dump the image list
command -v docker && docker images > $METAEFFEKT_INV_WDIR/docker-images.txt || true

# adapt ownership of extracted files to match folder creator user and group
chown "stat -c '%u' $METAEFFEKT_INV_WDIR":"stat -c '%g' $METAEFFEKT_INV_WDIR" -R $METAEFFEKT_INV_WDIR
