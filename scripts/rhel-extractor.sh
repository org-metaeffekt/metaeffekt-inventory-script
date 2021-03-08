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

# -- variables --

# the directory to store files in, both temporary and output files
Metaeffekt_Inv_Basedir="/var/tmp/inventory"

# TODO: get some sort of machine ID

# get current uuid
correlationuuid="$(cat $Metaeffekt_Inv_Basedir/correlation-uuid)"


# -- functions --


# -- basic script stuff, check input etc

echo "Executing $0"

# check the input flag
if [ "$1" != "--update" ] && [ "$1" != "--full" ]; then
    echo "$0: Invalid flag."
    exit 1
fi

# create folder structure in analysis folder (assuming sufficient permissions)
mkdir -p "$Metaeffekt_Inv_Basedir"

# if script runs a new full check, generate a new uuid
if [ "$1" == "--full" ]; then
  # store new uuid per last full run
  rm -f "$Metaeffekt_Inv_Basedir/correlation-uuid"
  uuidgen > "$Metaeffekt_Inv_Basedir/corellation-uuid"
  # update corellationuuid variable
  correlationuuid="$(cat $Metaeffekt_Inv_Basedir/correlation-uuid)"
fi

# crash if running in update mode but uuid has never been generated
if [ "$1" == "--update" ] && [ ! -f "$Metaeffekt_Inv_Basedir/correlation-uuid" ]; then
  echo "UUID file missing. Has full ever been run?"
  exit 1
fi

# -- collect relevant data --

# generate a json file containing all packages currently installed
rpm -qa --qf '\{"name":"%{NAME}","version":"%{VERSION}","license":"%{LICENSE}"\}\n' | sort > "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json"


# -- process data for filebeat --

# if we're doing a new full check, just copy the file. else run difference, then overwrite full file with the current status
if [ "$1" == "--full" ]; then
  mv -f "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json" "$Metaeffekt_Inv_Basedir/inventory-full.json"


elif [ "$1" == "--update" ]; then
  comm -13 "$Metaeffekt_Inv_Basedir/inventory-full.json" "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json" > "$Metaeffekt_Inv_Basedir/inventory-update.json"
  mv "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json" "$Metaeffekt_Inv_Basedir/inventory-full.json"
fi


# -- delete leftover files --
rm -f "$Metaeffekt_Inv_Basedir/inventory-update.json"
