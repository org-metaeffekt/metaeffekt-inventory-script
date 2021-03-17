Name: metaeffekt-inventory-script
Version: %(git describe --tags)
Release: 1%{?dist}
Summary: Scripts for creating an inventory of software components on a machine.

License: ASL 2.0
URL: https://github.com/org-metaeffekt/metaeffekt-inventory-script
Source0: metaeffekt-inventory-script-src.tar.gz

BuildRequires: bash
BuildRequires: coreutils
BuildRequires: git
Requires: bash
Requires: coreutils
Requires: cronie
Requires: cronie-anacron
Requires: rpm
Requires: sed
Requires: util-linux

BuildArch: noarch

%define metaeffekt_installdir /opt/metaeffekt/inventory

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
install -m 755 scripts/cronfiles/metaeffekt-inventory-full %{buildroot}/etc/cron.monthly/metaeffekt-inventory-full
install -m 755 scripts/cronfiles/metaeffekt-inventory-update %{buildroot}/etc/cron.daily/metaeffekt-inventory-update

%post
%{metaeffekt_installdir}/rhel-extractor.sh --full

%files
%license LICENSE
%{metaeffekt_installdir}/rhel-extractor.sh
/etc/cron.monthly/metaeffekt-inventory-full
/etc/cron.daily/metaeffekt-inventory-update

%changelog
