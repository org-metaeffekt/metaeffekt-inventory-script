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
# shall not contain spaces
METAEFFEKT_INV_BASEDIR="/var/tmp/inventory"

echo "Executing rhel-extractor.sh"

# create folder structure in analysis folder (assuming sufficient permissions)
mkdir -p $METAEFFEKT_INV_BASEDIR/package-meta

# generate a json file containing all packages currently installed
rpm -qa --qf '\{"name":%{NAME},"version":%{VERSION},"license":%{LICENSE}\}\n' > $METAEFFEKT_INV_BASEDIR/inventory-full.json



## examine distributions metadata
#uname -a > $METAEFFEKT_INV_BASEDIR/uname.txt
#cat /etc/issue > $METAEFFEKT_INV_BASEDIR/issue.txt
#cat /etc/redhat-release > $METAEFFEKT_INV_BASEDIR/release.txt

## list packages
#rpm -qa --qf '| %{NAME} | %{VERSION} | %{LICENSE} |\n' | sort > $METAEFFEKT_INV_BASEDIR/packages_rpm.txt

## list packages names (no version included)
#rpm -qa --qf '%{NAME}\n' | sort > $METAEFFEKT_INV_BASEDIR/packages_rpm-name-only.txt

## query package metadata and covered files
#packagenames="$(cat $METAEFFEKT_INV_BASEDIR/packages_rpm-name-only.txt)"
#for package in $packagenames
#do
#  rpm -qi $package > $METAEFFEKT_INV_BASEDIR/package-meta/${package}_rpm.txt
#done

## if docker is installed dump the image list
#command -v docker && docker images > $METAEFFEKT_INV_BASEDIR/docker-images.txt || true

## adapt ownership of extracted files to match folder creator user and group
#chown "$(stat -c '%u' $METAEFFEKT_INV_BASEDIR)":"$(stat -c '%g' $METAEFFEKT_INV_BASEDIR)" -R $METAEFFEKT_INV_BASEDIR
