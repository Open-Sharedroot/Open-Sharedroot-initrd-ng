#
# $Id: glusterfs-lib.sh,v 1.6 2010-06-25 12:52:28 marc Exp $
#
# @(#)$File$
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

#
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    glusterfs-mountopt=...  The mount options given to the mount command (i.e. noatime,nodiratime)
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output

#****h* comoonics-bootimage/glusterfs-lib.sh
#  NAME
#    glusterfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

#****f* boot-scripts/etc/clusterfs-lib.sh/glusterfs_getdefaults
#  NAME
#    glusterfs_getdefaults
#  SYNOPSIS
#    glusterfs_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function glusterfs_getdefaults {
	local param=$1
	case "$param" in
		mount_opts|mountopts)
		    echo "noatime,nodiratime"
		    ;;
		rootfs|root_fs)
		    echo "glusterfs"
		    ;;
	    scsi_failover|scsifailover)
	        echo "mapper"
	        ;;
	    ip)
	        echo "cluster"
	        ;;
	    *)
	        return 0
	        ;;
	esac
}
#********** glusterfs_getdefaults

#****f* glusterfs-lib.sh/glusterfs_get_drivers
#  NAME
#    glusterfs_get_drivers
#  SYNOPSIS
#    function glusterfs_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function glusterfs_get_drivers {
	echo "fuse"
}
#************ glusterfs_get_drivers

#****f* glusterfs-lib.sh/glusterfs_load
#  NAME
#    glusterfs_load
#  SYNOPSIS
#    function glusterfs_load()
#  DESCRIPTION
#    This function loads all relevant glusterfs modules
#  IDEAS
#  SOURCE
#
function glusterfs_load {
  ## THIS will be overwritten for rhel5 ##

  GLUSTERFS_MODULES=$(glusterfs_get_drivers)

  echo_local -n "Loading GlusterFS modules ($GLUSTERFS_MODULES)..."
  for module in ${GLUSTERFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ glusterfs_load

#****f* glusterfs-lib.sh/glusterfs_services_start
#  NAME
#    glusterfs_services_start
#  SYNOPSIS
#    function glusterfs_services_start()
#  DESCRIPTION
#    This function loads all relevant glusterfs modules
#  IDEAS
#  SOURCE
#
function glusterfs_services_start {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1
  local rootsource=$(glusterfs_get_rootsource $cluster_conf $nodename)
  echo_local "cluster_conf: $cluster_conf"
  echo_local "nodename: $nodename"
  echo_local "rootsource: $rootsource"

  echo_local "Mounting tmproot $rootsource /mnt/tmproot"
  mkdir /mnt/tmproot 2>/dev/null
  exec_local mount $rootsource /mnt/tmproot
  
  return $return_c
}
#************ glusterfs_services_start

#****f* glusterfs-lib.sh/glusterfs_services_restart_newroot
#  NAME
#    glusterfs_services_restart_newroot
#  SYNOPSIS
#    function glusterfs_services_restart_newroot()
#  DESCRIPTION
#    This function starts all needed services in newroot
#  IDEAS
#  SOURCE
#
function glusterfs_services_restart_newroot() {
  ## THIS will be overwritten for rhel5 ##
  exec_local /bin/true
}
#************ glusterfs_services_restart_newroot

#****f* glusterfs-lib.sh/glusterfs_init
#  NAME
#    glusterfs_init
#  SYNOPSIS
#    function glusterfs_init(start|stop|restart)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function glusterfs_init {
	return 0
}
#********* glusterfs_init

#****f* glusterfs-lib.sh/glusterfs_get_userspace_procs
#  NAME
#    glusterfs_get_userspace_procs
#  SYNOPSIS
#    function glusterfs_get_userspace_procs(cluster_conf, nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function glusterfs_get_userspace_procs {
   local clutype=$1
   local rootfs=$2

   echo -e "glusterfs \n\
glusterfsd"
}
#******** glusterfs_get_userspace_procs

#****f* boot-scripts/etc/clusterfs-lib.sh/glusterfs_get
#  NAME
#    glusterfs_get
#  SYNOPSIS
#    glusterfs_get [cluster_conf] [querymap] opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
glusterfs_get() {
   cc_get $@
}
# *********** glusterfs_get

# $Log: glusterfs-lib.sh,v $
# Revision 1.6  2010-06-25 12:52:28  marc
# - ext3/ocfs2/nfs/glusterfs-lib.sh:
#   - added ext3/ocfs2/nfs/glusterfs_get
#
# Revision 1.5  2009/09/28 13:00:55  marc
# - removed glusterfs_get_mountopts as this is called in the cluster library not in the fs library
#
# Revision 1.4  2009/08/11 09:54:08  marc
# - Latest glusterfs-lib.sh upstream patches (gordan bobic)
#
# Revision 1.3  2009/04/14 14:54:16  marc
# - added get_drivers functions
#
# Revision 1.2  2009/01/28 10:01:42  marc
# First shot for:
# Removed everything that is defined and therefore called from gfs-lib.sh ({clutype}_lib.sh) and left everything that is defined by glusterfs-lib.sh ({rootfs}-lib.sh).
#
# Revision 1.1  2009/01/28 09:40:12  marc
# Import from Gordan Bobic.
#
