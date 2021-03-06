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

# $Id: comoonics-bootimage-initscripts-el5.spec,v 1.30 2011/02/28 14:27:42 marc Exp $
#
##
##

%define _user root
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/comoonics-bootimage
%define SBINDIR   /sbin
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

Name: comoonics-bootimage-initscripts
Summary: Initscripts used by the OSR cluster environment.
Version: 1.4
BuildArch: noarch
Requires: comoonics-bootimage >= 1.4-80
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-bootimage-listfiles-rhel
Requires: comoonics-bootimage-listfiles-rhel6
#Conflicts: 
Release: 1.rhel6
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-initscripts-%{version}.tar.gz
License: GPL
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Initscripts used by the OSR cluster environment.
 

%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
# Files for compat
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 initscripts/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr
install -m755 initscripts/mountcdsls $RPM_BUILD_ROOT/%{INITDIR}/mountcdsls
install -d -m 755 $RPM_BUILD_ROOT/%{APPDIR}/patches
install -d $RPM_BUILD_ROOT/%{SBINDIR}
install -m755 initscripts/halt.local $RPM_BUILD_ROOT/%{SBINDIR}/halt.local

%preun
if [ "$1" -eq 0 ]; then
  echo "Preuninstalling comoonics-bootimage-initscripts"
  /sbin/chkconfig --del bootsr
  # we patch all versions here
  for initscript in halt network netfs; do
	if grep "comoonics patch " /etc/init.d/$initscript > /dev/null; then
		# the old way
		if [ -e /opt/atix/comoonics-bootimage/patches/${initscript}.patch ]; then
		   patchfile="/opt/atix/comoonics-bootimage/patches/${initscript}.patch"
		   echo -n "Unpatching initscript($patchfile)"
		   cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
		   if [ $? -ne 0 ]; then
		      echo >&2
		      echo >&2
		      echo "FAILURE!!!!" >&2
		      echo "Patching $initscript with patch $patchfile" >&2
		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
		      echo >&2
		   fi
		   echo
		else
		   echo -n "Unpatching $initscript ("
		   for patchfile in $(ls -1 /opt/atix/comoonics-bootimage/patches/${initscript}-*.patch | sort -r); do
			  echo -n $(basename $patchfile)", "
			  cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
		      if [ $? -ne 0 ]; then
		      echo >&2
		      echo >&2
		      echo "FAILURE!!!!" >&2
		      echo "Patching $initscript with patch $patchfile" >&2
		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
		      echo >&2
		      fi
		   done
		   echo ")"
		fi
	fi
  done
fi


%pre

#if this is an upgrade we need to unpatch all files
if [ "$1" -eq 2 ]; then
  # we patch all versions here
  for initscript in halt network netfs; do
	if grep "comoonics patch " /etc/init.d/$initscript > /dev/null; then
		# the old way
		if [ -e /opt/atix/comoonics-bootimage/patches/${initscript}.patch ]; then
		   patchfile="/opt/atix/comoonics-bootimage/patches/${initscript}.patch"
		   echo -n "Unpatching initscript($patchfile)"
		   cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
		   if [ $? -ne 0 ]; then
		      echo >&2
		      echo >&2
		      echo "FAILURE!!!!" >&2
		      echo "Patching $initscript with patch $patchfile" >&2
		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
		      echo >&2
		   fi
		   echo
		else
		   echo -n "Unpatching $initscript ("
		   for patchfile in $(ls -1 /opt/atix/comoonics-bootimage/patches/${initscript}-*.patch | sort -r); do
			  echo -n $(basename $patchfile)", "
			  cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
		      if [ $? -ne 0 ]; then
		      echo >&2
		      echo >&2
		      echo "FAILURE!!!!" >&2
		      echo "Patching $initscript with patch $patchfile" >&2
		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
		      echo >&2
		      fi
		   done
		   echo ")"
		fi
	fi
  done
fi 

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

services=""
echo "Disabling services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &> /dev/null
done

/bin/true

%postun
if [ -L %{SBINDIR}/halt.local ]; then
   rm %{SBINDIR}/halt.local
fi

%files

%attr(755, root, root) %{INITDIR}/bootsr
%attr(755, root, root) %{INITDIR}/mountcdsls
%attr(755, root, root) %{SBINDIR}/halt.local

%clean
rm -rf %{buildroot}

%changelog
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 1.4-20el5
- halt.local will now be a file being installed instead of a symbolic link.
# ------
# $Log: comoonics-bootimage-initscripts-el5.spec,v $
