#****h* comoonics-bootimage/comoonics-bootimage.spec
#  NAME
#    comoonics-bootimage-initscripts.spec
#    $id$
#  DESCRIPTION
#    initscripts for the Comoonics bootimage
#  AUTHOR
#    Mark Hlawatschek
#
#*******
# @(#)$File:$
#
# Copyright (c) 2001 ATIX GmbH, 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# $Id: comoonics-bootimage-initscripts-el4.spec,v 1.8 2008/02/29 09:10:41 mark Exp $
#
##
##

%define _user root
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/%{name}
%define LIBDIR    /opt/atix/%{name}
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

Name: comoonics-bootimage-initscripts
Summary: Initscripts used by the OSR cluster environment for Novell SLES10.
Version: 1.4
BuildArch: noarch
Requires: comoonics-bootimage >= 1.4-55
Requires: comoonics-bootimage-listfiles-sles11
Requires: sysvinit-comoonics
#Conflicts:
Release: 11.sles11
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-initscripts-%{version}.tar.gz
License: GPL
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Initscripts used by the OSR cluster environment. These are for Novell SLES11.


%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 initscripts/sles11/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr
install -m755 initscripts/mountcdsls $RPM_BUILD_ROOT/%{INITDIR}/mountcdsls
install -m755 initscripts/halt.local $RPM_BUILD_ROOT/%{INITDIR}/halt.local

%clean
rm -rf %{buildroot}

%postun

%post

echo "Starting postinstall.."
services="bootsr mountcdsls"
echo "Resetting services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &>/dev/null
   /sbin/chkconfig --add $service
   /sbin/chkconfig $service on
   /sbin/chkconfig --list $service
done

services="o2cb"
echo "Disabling services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &> /dev/null
   /sbin/chkconfig $service off &> /dev/null
done

/bin/true

%preun
true

%files
%attr(755, root, root) %{INITDIR}/bootsr
%attr(755, root, root) %{INITDIR}/mountcdsls
%attr(755, root, root) %{INITDIR}/halt.local

%changelog
* Tue Feb 22 2011 Marc Grimme <grimme@atix.de> 1.4-11sles11
- initscripts/rhel4,rhel5,fedora,sles10,sles11/bootsr
  - would work without cdsl tools being available
* Tue Feb 09 2011 Marc Grimme <grimme@atix.de> 1.4-10sles11
- initscripts/sles11/halt.local
  - moved from link to script calling bash and com-halt.sh.
* Wed Aug 18 2010 Marc Grimme <grimme@atix.de> 1.4-9sles11
- initscripts/rhel4,rhel5,fedora,sles10,sles11/bootsr
  - fixed bug #382 where the cdsl.local was not remounted in /etc/mtab on locally installed systems
* Thu Jul 08 2010 Marc Grimme <grimme@atix.de> 1.4-8.sles11
- bootsr uses bash as shell
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 1.4-7.sles11
- introduced mountcdsls
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-6.sles11
- more backports with cdsl mounts and enable bootsr
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-5.sles11
- more backports with cdsl mounts and enable bootsr
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-4.sles11
- more backports with cdsl mounts and enable bootsr
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-3.sles11
- Backported bootsr from RHEL5
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> 1.4-1.sles11
- Finalized new version
- added /etc/init.d/halt.local link instead of using boot.localfs
* Wed Nov 19 2008 Marc Grimme <grimme@atix.de> 1.4-1-sles11
- first revision

# ------
# $Log: comoonics-bootimage-initscripts-el4.spec,v $
