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


# rather fail earlier than later
set -e

# -- variables --

# the directory to store files in, both temporary and output files
Metaeffekt_Inv_Basedir="/var/tmp/inventory"
Metaeffekt_Inv_Outfile="$Metaeffekt_Inv_Basedir/inventory-out.json"

# -- basic script stuff, check input etc

echo "Executing $0"

# check the input flag
if [ "$1" != "--update" ] && [ "$1" != "--full" ]; then
    echo "$0: Invalid flag."
    exit 1
fi

# create folder structure in analysis folder (assuming sufficient permissions)
mkdir -p "$Metaeffekt_Inv_Basedir"

# -- prepare json tags --

# decide when to use a new correlation id or use old one
correlationuuid="NONE"
if [ "$1" == "--full" ]; then
  # store new uuid per last full run
  rm -f "$Metaeffekt_Inv_Basedir/correlation-uuid"
  uuidgen > "$Metaeffekt_Inv_Basedir/correlation-uuid"
  # update correlationuuid variable
  correlationuuid="$(cat "$Metaeffekt_Inv_Basedir/correlation-uuid")"
elif [ ! -f "$Metaeffekt_Inv_Basedir/correlation-uuid" ]; then
  echo "UUID file missing. Has full ever been run?"
  exit 1
else
  correlationuuid="$(cat "$Metaeffekt_Inv_Basedir/correlation-uuid")"
fi
# if correlation ID is still NONE by now, something went awfully wrong.

# get an application specific machine id as per machine-id man page
# keyed sha256 function with the machine id generates our id
machineidhash="$(cat /etc/machine-id | (echo -n "inventory-script" && cat - && echo -n "machine-id-gen-61a54fdadaaae669") | sha256sum | cut -b 1-64)"

# correlationid tag to be added to inventory messages (packages etc)
cortag="$(printf '"correlationid":"%s"' "$correlationuuid")"
packagetag="$(printf '"mtype":"package",%s' "$cortag")"
osinfotag="$(printf '"mtype":"osinfo",%s' "$cortag")"

dockertag="$(printf '"mtype":"image","container":"docker",%s' "$cortag")"

# -- collect relevant data --

# generate a json file containing all packages currently installed into a new temporary full state file
rpm -qa --qf "\{$packagetag," --qf '"name":"%{NAME}","version":"%{VERSION}","release":"%{RELEASE}","arch":"%{ARCH}","group":"%{GROUP}","license":"%{LICENSE}","sourcerpm":"%{SOURCERPM}","packager":"%{PACKAGER}","vendor":"%{VENDOR}","url":"%{URL}"\}\n' > "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json"

# if docker is installed, get data about docker images
command -v docker &>/dev/null && docker images --all --no-trunc --format '{"repository":"{{.Repository}}","tag":"{{.Tag}}","imageid":"{{.ID}}","createdat":"{{.CreatedAt}}","size":"{{.Size}}"}' | sed "s/^{/{$dockertag,/g" >> "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json"

# collect os info
osrelinfo=""
if [ -f /etc/osrelease ]; then
  osprettyname="$(sed -n "s/\"//g;s/^PRETTY_NAME=//p" /etc/os-release)"
  oscpename="$(sed -n "s/\"//g;s/^CPE_NAME=//p" /etc/os-release)"
  osrelinfo="$(printf '"release":"%s","cpe":"%s"' "$osprettyname" )"
fi

unames="$(uname -s)"
unamer="$(uname -r)"
unamev="$(uname -v)"
unamem="$(uname -m)"
unameo="$(uname -o)"

unameall="$(printf '"unames":"%s","unamer":"%s","unamev":"%s","unamem":"%s","unameo":"%s"' "$unames" "$unamer" "$unamev" "$unamem" "$unameo")"

# create osinfo object
printf '{%s,%s,%s}' "$osinfotag" "$osrelinfo" "$unameall" >> "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json"

# sort everything
sort -o "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json" "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json"

# -- process data for filebeat --

# if we're doing a new full check, just copy the file. else run difference, then overwrite full file with the current status
if [ "$1" == "--full" ]; then
  mv -f "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json" "$Metaeffekt_Inv_Basedir/inventory-full.json"

  # get an iso timestamp of current run in UTC
  timestamp="$(date -u --iso-8601=seconds)"

  # build host object
  hostobj="$(printf '{"mtype":"host","machineidhash":"%s",%s,"time":"%s"}' "$machineidhash" "$cortag" "$timestamp")"

  # send host object
  printf "%s\n" "$hostobj" >> "$Metaeffekt_Inv_Outfile"

  # send full list
  cat "$Metaeffekt_Inv_Basedir/inventory-full.json" >> "$Metaeffekt_Inv_Outfile"

elif [ "$1" == "--update" ]; then
  # generate new list of packages that were added since the last run
  comm -13 "$Metaeffekt_Inv_Basedir/inventory-full.json" "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json" > "$Metaeffekt_Inv_Basedir/inventory-update.json"

  # send package list
  cat "$Metaeffekt_Inv_Basedir/inventory-update.json" >> "$Metaeffekt_Inv_Outfile"

  # after update was run, update the full state json.
  mv "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json" "$Metaeffekt_Inv_Basedir/inventory-full.json"
fi


# -- make sure that unneeded files are deleted --
rm -f "$Metaeffekt_Inv_Basedir/inventory-full.tmp.json"
rm -f "$Metaeffekt_Inv_Basedir/inventory-update.json"
