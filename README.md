# metaeffekt-inventory-script

Scripts for creating an inventory of software components on a machine.


## Installation

Once you have built a package, install it using your operating system’s package manager.
As of writing this, the repository contains packaging scripts for RPM and DEB packages.

`# dnf install [filename]`

`# apt install ./[filename]`

With apt, use ./ at the beginning. Otherwise it may not recognize your deb file as a file, search for the filename as a package name and print “unable to locate package”.

## Configuration

The package itself does not require configurations to run.

The output is made to be read by filebeat.
Processing scripts might expect well-formed json lines as input, therefore filebeat should be configured to put the script's data in its own separate index.

A basic filebeat configuration may look like this:
```
# Input
- type: log
  index: "ae-inventory-%{[agent.version]}-%{+yyyy.MM.dd}"
  enabled: true
  json.keys_under_root: false
  close_renamed: true
  close_removed: true
  clean_removed: true
  paths:
    - /var/opt/metaeffekt/inventory/inventory-out.json

# If this is the only input and ilm isn't used, uncomment
# this line to disable ilm. If ilm is enabled, an extra
# empty index will be automatically created since the
# input's index override is not effective for setup.
#setup.ilm.enabled: false
```
