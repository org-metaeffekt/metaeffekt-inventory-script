Name: metaeffekt-inventory-script
Version: %(git describe --tags --abbrev=16 | sed "s/-/./g")
Release: 1%{?dist}
Summary: Scripts for creating an inventory of software components on a machine.

License: ASL 2.0
URL: https://github.com/org-metaeffekt/metaeffekt-inventory-script
Source0: metaeffekt-inventory-script-src.tar.gz

BuildRequires: bash
BuildRequires: coreutils
BuildRequires: git
BuildRequires: gzip
BuildRequires: sed
BuildRequires: tar
Requires: bash
Requires: coreutils
Requires: cronie
Requires: cronie-anacron
Requires: procps-ng
Requires: rpm
Requires: sed
Requires: util-linux

BuildArch: noarch

%define metaeffekt_installdir /opt/metaeffekt/inventory
%define metaeffekt_invdir /var/tmp/inventory

%description

%prep
tar -xf %{_sourcedir}/metaeffekt-inventory-script-src.tar.gz

%build

%install
mkdir -p %{buildroot}/%{metaeffekt_installdir}


install -m 755 scripts/rhel-extractor.sh %{buildroot}/%{metaeffekt_installdir}/rhel-extractor.sh

# need to create cron dummy dirs
mkdir -p %{buildroot}/etc/cron.monthly
mkdir -p %{buildroot}/etc/cron.daily
install -m 755 scripts/cronfiles/metaeffekt-inventory-rhel-full %{buildroot}/etc/cron.monthly/metaeffekt-inventory-rhel-full
install -m 755 scripts/cronfiles/metaeffekt-inventory-rhel-update %{buildroot}/etc/cron.daily/metaeffekt-inventory-rhel-update

%post
%{metaeffekt_installdir}/rhel-extractor.sh --full

%postun
rm -f %{metaeffekt_invdir}/inventory-full.json
rm -f %{metaeffekt_invdir}/correlation-uuid

%files
%license LICENSE
%{metaeffekt_installdir}/rhel-extractor.sh
/etc/cron.monthly/metaeffekt-inventory-rhel-full
/etc/cron.daily/metaeffekt-inventory-rhel-update

%changelog
