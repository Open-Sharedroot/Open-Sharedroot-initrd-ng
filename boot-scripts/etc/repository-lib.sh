#
# $Id: repository-lib.sh,v 1.10 2011-02-11 11:13:55 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2008 ATIX AG.
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

#
#****h* comoonics-bootimage/repository-lib.sh
#  NAME
#    repository-lib.sh
#    $id$
#  DESCRIPTION
#    Library for std operations
#*******

# Prefix for every variable found in the repository
[ -z "$REPOSITORY_PREFIX" ] && REPOSITORY_PREFIX=""
# Where to store the repository
[ -z "$REPOSITORY_PATH" ] && REPOSITORY_PATH="/tmp"
# Repository name that is prefixed for any file used by the repository followed by a "."
[ -z "$REPOSITORY_DEFAULT" ] && REPOSITORY_DEFAULT="comoonics"
[ -z "$REPOSITORY_FS" ] && REPOSITORY_FS="_"

#****f* repository-lib.sh/repository_load
#  NAME
#    repository_load
#  SYNOPSIS
#    function repository_load(name)
#  DESCRIPTION
#    loads the repository into environment.
#  IDEAS
#  SOURCE
#
repository_load() {
#	local repository="$1"
#	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
#	for file in ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.*; do
#	  repository_get_value ${file#${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.} "" $repository
#    done
   true
}
#******* repository_load


#****f* repository-lib.sh/repository_normalize_value
#  NAME
#    repository_normalize_value
#  SYNOPSIS
#    function repository_normalize_value(value)
#  DESCRIPTION
#    normalizes a value
#  IDEAS
#  SOURCE
#
repository_normalize_value() {
	(echo "$1" | tr '-' '_') 2>/dev/null
}
#******* repository_normalize_value

#****f* repository-lib.sh/repository_store_value
#  NAME
#    repository_store_value
#  SYNOPSIS
#    function repository_store_value(key, value, repository_name)
#  DESCRIPTION
#    stores the key/value pair into the repository apropriate file with the name repository_name.key. 
#    If repository name is not given REPOSITORY_DEFAULT is used.
#    It also sets the environment variable ${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=$value
#  IDEAS
#  SOURCE
#
repository_store_value() {
	local key=$(repository_normalize_value $1)
	local value="__set__"
	if [ $# -gt 1 ]; then
		value="$2"
	fi
	local repository="$3"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	#eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=\"$value\""
	echo -n "$value" > ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key
	[ -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key ]
}
#******* repository_store_value

#****f* repository-lib.sh/repository_append_value
#  NAME
#    repository_append_value
#  SYNOPSIS
#    function repository_append_value(key, value, repository_name)
#  DESCRIPTION
#    appends the key/value pair into the repository with the name repository_name. 
#    If repository name is not give REPOSITORY_DEFAULT is used.
#  IDEAS
#  SOURCE
#
repository_append_value() {
	local key=$(repository_normalize_value $1)
	local repository="$3"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local value=$(repository_get_value $key "" $repository)
	#eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=${value}\"$2\""
	echo -n "$2" >> ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key
}
#******* repository_append_value

#****f* repository-lib.sh/repository_list_keys
#  NAME
#    repository_list_keys
#  SYNOPSIS
#    function repository_list_keys(repository_name)
#  DESCRIPTION
#    return a list of all variablenames found in the given repository
#  IDEAS
#  SOURCE
#
repository_list_keys() {
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local values=""
	local key=""
#	repository_load $repository
	for key in ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.*; do
		key="${key#${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.}"
		if [ "$key" != "*" ]; then
		  echo ${key}
        fi
   	done		
}
#******* repository_list_keys

#****f* repository-lib.sh/repository_list_values
#  NAME
#    repository_list_values
#  SYNOPSIS
#    function repository_list_values(quoted=0|1, repository_name)
#  DESCRIPTION
#    return a list of all variablevalues found in the given repository
#  IDEAS
#  SOURCE
#
repository_list_values() {
	local quoted="$1"
	[ -z "$quoted" ] && quoted=0
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local index=0
	local key
	for key in ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.*; do
		key="${key#${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.}"
		if [ "$key" != "*" ]; then
		  if [ -n "$quoted" ] && [ $quoted -eq 0 ]; then
		    echo "\"$(repository_get_value $key "" $repository)\""
		  else
		    echo "$(repository_get_value $key "" $repository)"
		  fi
		fi
   	done		
}
#******* repository_list_values

#****f* repository-lib.sh/repository_list_items
#  NAME
#    repository_list_items
#  SYNOPSIS
#    function repository_list_items(ofs, ls, repository_name)
#  DESCRIPTION
#    return a list of all variablevalues found in the given repository
#  IDEAS
#  SOURCE
#
repository_list_items() {
	local repository="$3"
	local OFS=" "
	local LS="\n"
	[ -n "$1" ] && OFS="$1"
	[ -n "$2" ] && LS="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local values=""
	local key
	for key in $(repository_list_keys $repository); do
		if repository_has_key $key $repository; then
	      values=${values}${LS}${key}${OFS}$(repository_get_value $key "" $repository)
		fi
  	done		
 	echo -e $values
}
#******* repository_list_items

#****f* repository-lib.sh/repository_get_value
#  NAME
#    repository_get_value
#  SYNOPSIS
#    function repository_get_value(key, default, repository_name)
#  DESCRIPTION
#    return the value from the repository with the name repository_name
#  IDEAS
#  SOURCE
#
repository_get_value() {
	local key=$(repository_normalize_value $1)
	local default=$2
	local repository="$3"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local value=
	if [ -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key ]; then
		value=$(cat ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key)
		#eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=\"$value\""
		echo "$value"
		return 0
    elif [ -n "$default" ]; then
        echo "$default"
        return 0
	else
	    return 1
    fi
}
#******* repository_get_value

#****f* repository-lib.sh/repository_has_key
#  NAME
#    repository_has_key
#  SYNOPSIS
#    function repository_has_key(key, repository_name)
#  DESCRIPTION
#    return if the key exists in repository
#  IDEAS
#  SOURCE
#
repository_has_key() { 
	local key=$(repository_normalize_value $1)
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	[ -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key ]
	return $?
}
#******* repository_has_key

#****f* repository-lib.sh/repository_del_value
#  NAME
#    repository_del_value
#  SYNOPSIS
#    function repository_del_value(key, repository_name)
#  DESCRIPTION
#    remove the given key from the repository.
#  IDEAS
#  SOURCE
#
repository_del_value() { 
	local key=$(repository_normalize_value $1)
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	val=$(repository_get_value $key "" $repository)
	if [ $? -eq 0 ]; then
		#eval "unset ${repository}${REPOSITORY_FS}${key}"
		rm -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key
	fi
}
#******* repository_del_value

#*****f* repository-lib.sh/repository_clear
#  NAME
#    repository_clear
#  SYNOPSIS
#    function repository_clear(repository_name)
#  DESCRIPTION
#    clears the given repository from disk
#  IDEAS
#  SOURCE
#
repository_clear() {
	local repository="$1"
	local key
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
  	for key in $(repository_list_keys $repository); do
  		repository_del_value $key $repository
   	done
}
#******** repository_clear

#*****f* repository-lib.sh/repository_store_parameters
#  NAME
#    repository_store_parameters
#  SYNOPSIS
#    function repository_store_parameters(prefix, parameters*)
#  DESCRIPTION
#    Stores all given parameters in the repository as ${prefix}"param"{index}.
#  IDEAS
#  SOURCE
#
repository_store_parameters() {
	local prefix=$1
	shift
	local paramname="param"
	for i in $(seq 1 $#); do
		repository_store_value ${prefix}${paramname}${i} $1
		shift
    done
}
#******** repository_store_parameters

#*****f* repository-lib.sh/repository_del_parameters
#  NAME
#    repository_del_parameters
#  SYNOPSIS
#    function repository_del_parameters(prefix, parameters*)
#  DESCRIPTION
#    Deletes all given parameters in the repository as ${prefix}"param"{index}.
#  IDEAS
#  SOURCE
#
repository_del_parameters() {
	local prefix=$1
	shift
	local paramname="param"
	for i in $(seq 1 $#); do
		repository_del_value ${prefix}${paramname}${i}
		shift
    done
}
#******** repository_del_parameters

#############
# $Log: repository-lib.sh,v $
# Revision 1.10  2011-02-11 11:13:55  marc
# - repository_normalize_value
#     - cosmetic change
#
# Revision 1.9  2010/07/08 08:11:39  marc
# - added function repository_store_parameters and repository_del_parameters being used by exec_local
# - removed that the repository_values are stored in the environment (obsolete and not used)
#
# Revision 1.8  2010/02/09 21:44:25  marc
# typo
#
# Revision 1.7  2010/02/05 12:40:40  marc
# - repository_load is obsolete
#
# Revision 1.6  2010/01/11 10:06:01  marc
# bugfix for multiple attributes for attribute
#
# Revision 1.5  2010/01/04 13:14:42  marc
# typos
#
# Revision 1.4  2009/09/28 13:05:29  marc
# - backported repository-lib from osr-dracut
# - moved to new implementation multiple files instead of one repository file
#
# Revision 1.1  2009/08/13 09:25:46  marc
# initial revision
#
# Revision 1.3  2009/01/28 12:55:50  marc
# - some bugfixes
# - cleaned the code
# - added functions to make better use of it (clean, del, append)
#