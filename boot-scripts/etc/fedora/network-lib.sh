#
# $Id: network-lib.sh,v 1.2 2009-04-14 14:48:01 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
#****h* boot-scripts/etc/fedora9/network-lib.sh
#  NAME
#    network-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for network support functions for RHEL5.
#*******


function fedora10_ip2Config() {
	fedora9_ip2Config $*
}

#****f* boot-lib.sh/fedora9_ip2Config
#  NAME
#    fedora9_ip2Config
#  SYNOPSIS
#    function fedora9_ip2Config(ipDevice, ipAddr, ipGate, ipNetmask, ipHostname) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function fedora9_ip2Config() {
  local ipDevice=$1
  local ipAddr=$2

  echo "$ipAddr" | grep "[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*" </dev/null 2>&1
  if [ -n "$ipAddr" ]; then
    local ipNetmask=$3
    local ipHostname=$4
    local ipGate=$5
  else
    local master=$3
    local slave=$4
  fi
  local MAC=$6
  local type=$7
  local bridge=$8
  local onboot=$9

  # reformating MAC from - to :
  MAC=${MAC//-/:}

  if [ -z "$type" ]; then type="Ethernet"; fi
  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  if [ -e ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ]; then
    mv -f ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ${__prefix}/etc/sysconfig/network-scripts/ifcfg-${ipDevice}.com_back
  fi

  (echo "DEVICE=$ipDevice" &&
   echo "ONBOOT=$onboot" &&
   echo "TYPE=$type") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice

  [ -n "$MAC" ] && [ "$MAC" != "00:00:00:00:00:00" ] && echo "HWADDR=$MAC" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice

  # test for vlan config
  if [[ "$ipDevice" =~ "[a-z]+[0-9]+\.[0-9]+" ]]; then
	echo "VLAN=yes" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  fi

  if [ -n "$ipAddr" ]; then
    if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then
      bootproto="dhcp"
    else
      bootproto="static"
    fi

    echo "BOOTPROTO=$bootproto" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
    if [ "$bootproto" != "dhcp" ]; then
      (echo "IPADDR=$ipAddr" &&
       if [ -n "$ipNetmask" ]; then echo "NETMASK=$ipNetmask"; fi) >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
      if [ -n "$ipGate" ]; then
	    echo "GATEWAY=$ipGate" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
      fi
    fi
  else
     [ -n "$master" ] && echo "MASTER=${master}" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     [ -n "$slave" ] &&  echo "SLAVE=${slave}"   >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     [ -n "$bridge" ] && echo "BRIDGE=${bridge}" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  fi
  return 0
}
#************ fedora9_ip2Config

#################
# $Log: network-lib.sh,v $
# Revision 1.2  2009-04-14 14:48:01  marc
# added fedora10 functions
#
# Revision 1.1  2009/01/28 12:45:29  marc
# initial revision.
# Support for fedora
#
# Revision 1.4  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#
# Revision 1.3  2008/08/14 13:32:01  marc
# - rewrote briding
# - fix mac bug
#
# Revision 1.2  2008/01/24 13:35:15  marc
# - RFE#145 macaddress will be generated in configuration files
#
# Revision 1.1  2007/09/07 07:57:55  mark
# initial check in
#
# Revision 1.3  2007/01/19 10:04:16  mark
# added vlan support
#
# Revision 1.2  2006/05/12 13:03:24  marc
# First stable version 1.0.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
