#!/usr/bin/env bash
# xxx THIS FILE IS GENERATED BY asgs-brew.pl                                           xxx
# xxx DO NOT CUSTOMIZE THIS FILE, IT WILL BE OVERWRITTEN NEXT TIME asgs-brew.pl IS RUN xxx

# This file is part of the ADCIRC Surge Guidance System (ASGS).
#
# The ASGS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ASGS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the ASGS.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------

# Developer Note:
# This must remain consistent with what's exported by asgs-brew.pl, and
# vice versa; if something is added in define(), be sure to add the
# corresponding entry in show() - including usage

help() {
  echo Command Line Options \(used when invoking asgsh from login shell\):
  echo "   -h                         - displays available asgsh command line flags, then exits."
  echo "   -p     profile             - launches the ASGS Shell environment and immediate loads specified profile on start, if it exists."
  echo
  echo ASGS Shell Commands:
  echo "   define config              - defines ASGS configuration file used by 'run', (\$ASGS_CONFIG). 'define' replaces old 'set' command."
  echo "          editor              - defines default editor, (\$EDITOR)"
  echo "          scratchdir          - defines ASGS main script directory used by all underlying scripts, (\$SCRATCH)"
  echo "          scriptdir           - defines ASGS main script directory used by all underlying scripts, (\$SCRIPTDIR)"
  echo "          workdir             - defines ASGS main script directory used by all underlying scripts, (\$WORK)"
  echo "   delete profile <name>      - deletes named profile"
  echo "   delete adcirc  <name>      - deletes named ADCIRC profile"
  echo "   dump   <param>             - dumps (using cat) contents specified files: config, exported (variables); and if defined: statefile, syslog" 
  echo "   edit   adcirc  <name>      - directly edit the named ADCIRC environment file"
  echo "   edit   config              - directly edit currently registered ASGS configuration file (used by asgs_main.sh)"
  echo "   edit   profile <name>      - directly edit the named ASGSH Shell profile"
  echo "   edit   syslog              - open up SYSLOG in EDITOR for easier forensics"
  echo "   goto   <param>             - change CWD to a supported directory. Type 'goto options' to see the currently supported options"
  echo "   initadcirc                 - interactive tool for building and local registering versions of ADCIRC for use with ASGS"
  echo "   list   <param>             - lists different things, please see the following options; type 'list options' to see currently supported options"
  echo "   load   profile <name>      - loads a saved profile by name; use 'list profiles' to see what's available"
  echo "   load   adcirc  <name>      - loads information a version of ADCIRC into the current environment. Use 'list adcirc' to see what's available"
  echo "   purge  <param>             - deletes specified file or directory"
  echo "          rundir              - deletes run directory associated with a profile, useful for cleaning up old runs and starting over for the storm"
  echo "          statefile           - deletes the state file associated with a profile, effectively for restarting from the initial advisory"
  echo "   run                        - runs asgs using config file, \$ASGS_CONFIG must be defined (see 'define config'); most handy after 'load'ing a profile"
  echo "   save   profile <name>      - saves an asgs named profile, '<name>' not required if a profile is loaded"
  echo "   show   <param>             - shows specified profile variables, to see current list type 'show help'"
  echo "   show   exported            - dumps all exported variables and provides a summary of what asgsh tracks"
  echo "   sq                         - shortcut for \"squeue -u \$USER\" (if squeue is available)"
  echo "   tailf  syslog              - executes 'tail -f' on ASGS instance's system log"
  echo "   verify                     - verfies Perl and Python environments"
  echo "   exit                       - exits ASGS shell, returns \$USER to login shell"
}

# runs script to install ADCIRC interactively
initadcirc() {
  init-adcirc.sh
}

# deletes a saved profile by name
delete() {
  case "${1}" in
    adcirc)
      if [ -z "${2}" ]; then
        echo \'delete adcirc\' requires a name parameter, does NOT unload current ADCIRC settings 
        return
      fi
      NAME=${2}
      if [ -e "$ADCIRC_META_DIR/$NAME" ]; then
        rm -f "$ADCIRC_META_DIR/$NAME"
        echo deleted ADCIRC configuration \'$NAME\'
      else
        echo "no saved ADCIRC configuration named '$NAME' was found"
      fi
      ;;
    profile)
      if [ -z "${2}" ]; then
        echo \'delete profile\' requires a name parameter, does NOT unload current profile 
        return
      fi
      NAME=${2}
      if [ -e "$ASGS_HOME/.asgs/$NAME" ]; then
        rm -f "$ASGS_HOME/.asgs/$NAME"
        echo deleted profile \'$NAME\'
      else
        echo "no saved profile named '$NAME' was found"
      fi
      ;;
    *)
      echo "'delete' requires 2 parameters: 'adcirc' or 'profile' as the first; the second parameter defines what to load."
      return
  esac
}

# interactive dialog for choosing an EDITOR if not defined
_editor_check() {
  if [ -z "$EDITOR" ]; then
    __DEFAULT_EDITOR=vim
    echo "\$EDITOR is not defined. Please define it now (selection updates environment):"
    echo
    echo "Editors available via PATH"
    for e in vim nano vi; do
      full=$(which `basename $e`)
      echo "- $e	(full path: $full)"
    done 
    read -p "Choose [vim]: " _DEFAULT_EDITOR
    if [ -z "$_DEFAULT_EDITOR" ]; then
      _DEFAULT_EDITOR=$__DEFAULT_EDITOR
    fi
    define editor "$_DEFAULT_EDITOR"
    echo
  fi
}

# opens up $EDITOR to directly edit files defined by the case
# statement herein
edit() {
  # if it's not defined
  _editor_check

  # dispatch subject of edit command
  case "${1}" in
  adcirc)
    BRANCH=${2}
    if [ ! -e "$ADCIRC_META_DIR/$BRANCH" ]; then
      echo "An ADCIRC environment named '$BRANCH' doesn't exist"
      return
    fi
    $EDITOR "$ADCIRC_META_DIR/$BRANCH"
    ;;
  config)
    if [ -z "$ASGS_CONFIG" ]; then
      echo "\$ASGS_CONFIG is not defined. Use 'define config' to specify an ASGS config file."
      return
    fi
    $EDITOR $ASGS_CONFIG
    ;;
  profile)
    NAME=${2}
    if [ ! -e "$ASGS_HOME/.asgs/$NAME" ]; then
      echo "An ASGS profile named '$NAME' doesn't exist"
      return
    fi
    $EDITOR "$ASGS_HOME/.asgs/$NAME"
    ;;
  syslog)
    if [ ! -e "$SYSLOG" ]; then
      echo "Log file, '$NAME' doesn't exist"
      return
    fi
    $EDITOR "$SYSLOG"
    ;;
  *)
    echo "Supported options:"
    echo "adcirc <name>  - directly edit named ADCIRC environment file"
    echo "config         - directly edit ASGS_CONFIG, if defined"
    echo "profile <name> - directly edit named ASGS profile (should be followed up with the 'load profile' command"
    echo "syslog         - open SYSLOG from a run in EDITOR for easier forensices"
    ;;
  esac
}

# change to a directory know by asgsh
goto() {
  case "${1}" in
    adcircworkdir)
    if [ -e "$ADCIRCDIR/work" ]; then
      cd $ADCIRCDIR/work
      pwd
    else
      echo 'ADCIRCDIR not yet defined'
    fi 
    ;;
    adcircdir)
    if [ -e "$ADCIRCDIR" ]; then
      cd $ADCIRCDIR
      pwd
    else
      echo 'ADCIRCDIR not yet defined'
    fi 
    ;;
  rundir)
    if [ -e "$RUNDIR" ]; then
      cd $RUNDIR
      pwd
    else
      echo 'rundir not yet defined'
    fi 
    ;;
  scratchdir)
    if [ -e "$SCRATCH" ]; then
      cd $SCRATCH
      pwd
    else
      echo 'scratchdir not yet defined'
    fi 
    ;;
  scriptdir)
    if [ "$SCRIPTDIR" ]; then
      cd $SCRIPTDIR
      pwd
    else
      echo 'scriptdir not yet defined'
    fi 
    ;;
  workdir)
    if [ "$WORK" ]; then
      cd $WORKDIR
      pwd
    else
      echo 'workdir not yet defined'
    fi 
    ;;
  *)
    echo "Only 'adcircdir', 'rundir', 'scratchdir', 'scriptdir', and 'workdir' are supported at this time."
    ;;
  esac
}

# list interface for lists of important things (registered ADCIRC builds, ASGS profiles)
list() {
  case "${1}" in
    adcirc)
      if [ ! -d "$ADCIRC_META_DIR/" ]; then
        echo "nothing is available to list, run 'initadcirc' to build and register a version of ADCIRC"
      else
        for adcirc in $(ls -1 "$ADCIRC_META_DIR/" | sort); do
          echo "- $adcirc"
        done
        return
      fi
      ;;
    configs)
      read -p "Show configs for what year? " year
      if [ -d $SCRIPTDIR/config/$year ]; then
        ls $SCRIPTDIR/config/$year/* | less
      else
        echo ASGS configs for $year do not exist 
      fi
      ;;
    profiles)
      if [ ! -d "$ASGS_HOME/.asgs/" ]; then
        echo "nothing is available to list, use the 'save' command to save this profile"
      else
        for profile in $(ls -1 "$ASGS_HOME/.asgs/" | sort); do
          echo "- $profile"
        done
        return
      fi
      ;;
    *)
      echo "only 'list configs' and 'list profiles' are supported at this time.'"
      ;;
  esac 
}

# load environment related things like an ADCIRC environment or saved ASGS environment
load() {
  case "${1}" in
    adcirc)
      if [ -z "${2}" ]; then
        echo "'load' requires a name parameter, use 'list adcirc' to list available ADCIRC builds"
        return
      fi
      BRANCH=${2}
      if [ -e "${ADCIRC_META_DIR}/${BRANCH}" ]; then
          # source it
          . ${ADCIRC_META_DIR}/${BRANCH}
      else
          echo "ADCIRC build, '$BRANCH' does not exist. Use 'list adcirc' to see a which ADCIRCs are available to load"
      fi
      ;;
    profile)
      if [ -z "${2}" ]; then
        echo "'load' requires a name parameter, use 'list profiles' to list saved profiles"
        return
      fi
      NAME=${2}
      if [ -e "$ASGS_HOME/.asgs/$NAME" ]; then
        . "$ASGS_HOME/.asgs/$NAME"
        export PS1="asgs ($NAME)> "
        echo loaded \'$NAME\' into current profile;
        if [ -n "$ASGS_CONFIG" ]; then
          # extracts info such as 'instancename' so we can derive the location of the state file, then the log file path and actual run directory
          _parse_config $ASGS_CONFIG
        fi
        _ASGSH_CURRENT_PROFILE="${2}"
      else
        echo "ASGS profile, '$NAME' does not exist. Use 'list profile' to see a which profile are available to load"
      fi
      ;;
    *)
      echo "'load' requires 2 parameters: 'adcirc' or 'profile' as the first; the second parameter defines what to load."
      return
  esac
}

_parse_config() {
  if [ ! -e "${1}" ]; then
    echo "warning: config file is defined, but the file '${1}' does not exist!"
    return
  fi

  # pull out var info the old fashion way...
  INSTANCENAME=$(grep 'INSTANCENAME=' "${1}" | sed 's/^ *INSTANCENAME=//' | sed 's/ *#.*$//g')
  echo "config file found, instance name is '$INSTANCENAME'"

  STATEFILE="$SCRATCH/${INSTANCENAME}.state"
  echo "loading latest state file information from '${STATEFILE}'."

  _load_state_file $STATEFILE
}

_load_state_file() {
  if [ ! -e "${1}" ]; then
    echo "warning: state file '${1}' does not exist! No indication of first run yet?"
    return
  fi

  # we only are about RUNDIR and SYSLOG since they do not change from run to run 
  . $STATEFILE

  if [ -z "$RUNDIR" ]; then
    echo "warning: state file does not contain 'RUNDIR' information. Check again later."
    return
  fi

  if [ -z "$SYSLOG" ]; then
    echo "warning: state file does not contain 'SYSLOG' information. Check again later."
    return
  fi

  echo "... found 'RUNDIR' information, defined as '$RUNDIR'"
  echo "... found 'SYSLOG' information, defined as '$SYSLOG'"

  PROPERTIESFILE="$RUNDIR/run.properties"

  if [ -e "$PROPERTIESFILE" ]; then
    echo "... found 'run.properties' file, at '$PROPERTIESFILE'"
  fi
}

run() {
  if [ -n "${ASGS_CONFIG}" ]; then
    echo "Running ASGS using the config file, '${ASGS_CONFIG}'"

    # NOTE: asgs_main.sh automatically extracts $SCRIPTDIR based on where it is located;
    # this means that asgs_main.sh will respect $SCRIPTDIR defined here by virtue of this capability.
    $SCRIPTDIR/asgs_main.sh -c $ASGS_CONFIG
  else
    echo "ASGS_CONFIG must be defined before the 'run' command can be used";  
    return;
  fi
}

# saves environment as a file named what is passed to the command, gets the
# list of environmental variables to save from $_ASGS_EXPORTED_VARS
save() {
  case "${1}" in
    profile)
      DO_RELOAD=1
      if [ -n "${2}" ]; then 
        NAME=${2}
        DO_RELOAD=0
      elif [ -z "${NAME}" ]; then
        echo "'save' requires a name parameter or pre-loaded profile"
        return
      fi
    
      if [ ! -d $ASGS_HOME/.asgs ]; then
        mkdir -p $ASGS_HOME/.asgs
      fi
    
      if [ -e "$ASGS_HOME/.asgs/$NAME" ]; then
        IS_UPDATE=1
      fi
    ;;
    *)
      echo "'save' requires 2 parameters: 'profile' as the first; the second is the profile name."
      return
    return
  esac

  # generates saved provile as a basic shell resource file that simply
  # includes an 'export' line for each variable asgsh cares about; this
  # is defined as part of the shell installation by asgs-brew.pl
  for e in $_ASGS_EXPORTED_VARS; do
    echo "export ${e}='"${!e}"'"  >> "$ASGS_HOME/.asgs/${NAME}.$$.tmp"
  done
  mv "$ASGS_HOME/.asgs/${NAME}.$$.tmp" "$ASGS_HOME/.asgs/${NAME}"
  
  # update prompt so that it's easy to tell at first glance what's loaded
  export PS1="asgs ($NAME)> "

  # print different message based on whether or not the profile already exists
  if [ -n "$IS_UPDATE" ]; then
    echo profile \'$NAME\' was updated
  else
    echo profile \'$NAME\' was written
  fi

  if [ 1 -eq "$DO_RELOAD" ]; then
    load $NAME
  fi
}

# defines the value of various important environmental variables,
# exports them to current session (and are available to be saved)
define() {
  if [ -z "${2}" ]; then
    echo "'define' requires 2 arguments - parameter name and value"
    return 
  fi
  case "${1}" in
    adcircdir)
      export ADCIRCDIR=${2}
      echo "ADCIRCDIR is defined as '${ADCIRCDIR}'"
      ;;
    adcircbranch)
      export ADCIRC_GIT_BRANCH=${2}
      echo "ADCIRC_GIT_BRANCH is defined as '${ADCIRC_GIT_BRANCH}'"
      ;;
    adcircremote)
      export ADCIRC_GIT_REMOTE=${2}
      echo "ADCIRC_GIT_REMOTE is defined as '${ADCIRC_GIT_REMOTE}'"
      ;;
    config)
      # converts relative path to absolute path so the file is available regardless of the `pwd`
      ABS_PATH=$(readlink -f "${2}")
      # makes sure that file exists, will not 'define config' if the file does not
      if [ ! -e "$ABS_PATH" ]; then
        echo "'${ABS_PATH}' does not exist! 'define config' command has failed."
        return
      fi 
      export ASGS_CONFIG=${ABS_PATH}
      echo "ASGS_CONFIG is defined as '${ASGS_CONFIG}'"
      ;;
    editor)
      export EDITOR=${2}
      echo "EDITOR is defined as '${EDITOR}'"
      ;;
    scriptdir)
      export SCRIPTDIR=${2} 
      echo "SCRIPTDIR is now defined as '${SCRIPTDIR}'"
      ;;
    workdir)
      export WORK=${2} 
      echo "WORK is now defined as '${WORK}'"
      ;;
    scratchdir)
      export SCRATCH=${2} 
      echo "SCRATCH is now defined as '${SCRATCH}'"
      ;;
    *) echo "define requires one of the supported parameters: adcircdir, adcircbranch, adcircremote, config, editor, scratchdir, scriptdir, or workdir"
      ;;
  esac 
}

# prints value of provided variable name
dump() {
  if [ -z "${1}" ]; then
    echo "'dump' requires 1 argument - parameter"
    return 
  fi
  case "${1}" in
    config)
      if [ -n "${ASGS_CONFIG}" ]; then
        cat ${ASGS_CONFIG}
      else
        echo "ASGS_CONFIG is not defined as anything. Try, 'define config /path/to/asgs/config.sh' first"
      fi
      ;;
    exported)
      for e in $_ASGS_EXPORTED_VARS; do
        echo "${e}='"${!e}"'"
      done
      ;;
    statefile)
      if [ -n "${STATEFILE}" ]; then
        cat ${STATEFILE}
      else
        echo "STATEFILE is not defined as anything. Does state file exist?"
      fi
      ;;
    syslog)
      if [ -n "${SYSLOG}" ]; then
        cat ${SYSLOG}
      else
        echo "SYSLOG is not defined as anything. Does state file exist?"
      fi
      ;;
    *) echo "'dump' requires one of the supported parameters:"
       echo config exported statefile syslog
      ;;
  esac 
}

# prints value of provided variable name
show() {
  if [ -z "${1}" ]; then
    echo "'show' requires 1 argument - parameter"
    return 
  fi
  case "${1}" in
    config)
      if [ -n "${ASGS_CONFIG}" ]; then
        echo "ASGS_CONFIG is defined as '${ASGS_CONFIG}'"
      else
        echo "ASGS_CONFIG is not defined as anything. Try, 'define config /path/to/asgs/config.sh' first"
      fi
      ;;
    adcircbase)
      if [ -n "${ADCIRCBASE}" ]; then
        echo "ADCIRCBASE is defined as '${ADCIRCBASE}'"
      else
        echo "ADCIRCBASE is not defined as anything. Try, 'define adcircbase /path/to/adcirc/dir' first"
      fi
      ;;
    adcircdir)
      if [ -n "${ADCIRCDIR}" ]; then
        echo "ADCIRCDIR is defined as '${ADCIRCDIR}'"
      else
        echo "ADCIRCDIR is not defined as anything. Try, 'define adcircdir /path/to/adcirc/dir' first"
      fi
      ;;
    adcircbranch)
      if [ -n "${ADCIRC_GIT_BRANCH}" ]; then
        echo "ADCIRC_GIT_BRANCH is defined as '${ADCIRC_GIT_BRANCH}'"
      else
        echo "ADCIRC_GIT_BRANCH is not defined as anything. Try, 'define adcircbranch git-branch-tag-or-sha' first"
      fi
      ;;
    adcircremote)
      if [ -n "${ADCIRC_GIT_REMOTE}" ]; then
        echo "ADCIRC_GIT_REMOTE is defined as '${ADCIRC_GIT_REMOTE}'"
      else
        echo "ADCIRC_GIT_REMOTE is not defined as anything. Try, 'define adcircremote https://|ssh://adcirc-remote-url' first"
      fi
      ;;
    machinename)
      if [ -n "${ASGS_MACHINE_NAME}" ]; then
        echo "ASGS_MACHINE_NAME is defined as '${ASGS_MACHINE_NAME}'"
      else
        echo "ASGS_MACHINE_NAME is not defined as anything. This should have been defined via asgs-brew.pl."
      fi
      ;;
    adcirccompiler)
      if [ -n "${ADCIRC_COMPILER}" ]; then
        echo "ADCIRC_COMPILER is defined as '${ADCIRC_COMPILER}'"
      else
        echo "ADCIRC_COMPILER is not defined as anything. This should have been defined via asgs-brew.pl."
      fi
      ;;
    asgscompiler)
      if [ -n "${ASGS_COMPILER}" ]; then
        echo "ASGS_COMPILER is defined as '${ASGS_COMPILER}'"
      else
        echo "ASGS_COMPILER is not defined as anything. This should have been defined via asgs-brew.pl."
      fi
      ;;
    home)
      if [ -n "${ASGS_HOME}" ]; then
        echo "ASGS_HOME is defined as '${ASGS_HOME}'"
      else
        echo "ASGS_HOME is not defined as anything. This should have been defined via asgs-brew.pl."
      fi
      ;;
    installpath)
      if [ -n "${ASGS_INSTALL_PATH}" ]; then
        echo "ASGS_INSTALL_PATH is defined as '${ASGS_INSTALL_PATH}'"
      else
        echo "ASGS_INSTALL_PATH is not defined as anything. This should have been defined via asgs-brew.pl."
      fi
      ;;
    brewflags)
      if [ -n "${ASGS_BREW_FLAGS}" ]; then
        echo "ASGS_BREW_FLAGS is defined as '${ASGS_BREW_FLAGS}'"
      else
        echo "ASGS_BREW_FLAGS is not defined as anything. This should have been defined via asgs-brew.pl."
      fi
      ;;
    editor)
      if [ -n "${EDITOR}" ]; then
        echo "EDITOR is defined as '${EDITOR}'"
      else
        echo "EDITOR is not defined as anything. Try, 'define editor vi' first"
      fi
      ;;
    exported)
      for e in $_ASGS_EXPORTED_VARS; do
        echo "${e}='"${!e}"'"
      done
      ;;
    instancename)
      if [ -n "${INSTANCENAME}" ]; then
        echo "INSTANCENAME is defined as '${INSTANCENAME}'"
      else
        echo "INSTANCENAME is not defined as anything. Have you defined the config file yet?"
      fi
      ;;
    profile)
      if [ -n "${_ASGSH_CURRENT_PROFILE}" ]; then
        echo "profile is defined as '${_ASGSH_CURRENT_PROFILE}'"
      else
        echo "profile is not defined as anything. Does state file exist?" 
      fi
      ;;
    rundir)
      if [ -n "${RUNDIR}" ]; then
        echo "RUNDIR is defined as '${RUNDIR}'"
      else
        echo "RUNDIR is not defined as anything. Does state file exist?" 
      fi
      ;;
    scratchdir)
      if [ -n "${SCRATCH}" ]; then
        echo "SCRATCH is defined as '${SCRATCH}'"
      else
        echo "SCRATCH is not defined as anything. Try, 'define scratch /path/to/scratch' first"
      fi
      ;;
    scriptdir)
      if [ -n "${SCRIPTDIR}" ]; then
        echo "SCRIPTDIR is defined as '${SCRIPTDIR}'"
      else
        echo "SCRIPTDIR is not defined. This is concerning, please make sure your installation of ASGS is complete."
      fi
      ;;
    statefile)
      if [ -n "${STATEFILE}" ]; then
        echo "STATEFILE is defined as '${STATEFILE}'"
      else
        echo "STATEFILE is not defined as anything. Does state file exist?"
      fi
      ;;
    syslog)
      if [ -n "${SYSLOG}" ]; then
        echo "SYSLOG is defined as '${SYSLOG}'"
      else
        echo "SYSLOG is not defined as anything. Does state file exist?"
      fi
      ;;
    workdir)
      if [ -n "${WORK}" ]; then
        echo "WORK is defined as '${WORK}'"
      else
        echo "WORK is not defined as anything. Try, 'define config /path/to/work' first"
      fi
      ;;
    *) echo "'show' requires one of the supported parameters:"
       echo config adcircbase adcircdir adcircbranch adcircremote machinename adcirccompiler asgscompiler home
       echo installpath brewflags editor instancename rundir scratchdir scriptdir statefile syslog workdir
      ;;
  esac 
}

# short cut to report current work queue status
sq() {
  if [ -n $(which squeue) ]; then
    squeue -u $USER  
  else
    echo The `squeue` utility has not been found in your PATH \(slurm is not available\)
  fi
}

# short cut to tail -f the SYSLOG of the current ASGS package that is running
tailf() {
  if [ -z "${1}" ]; then
    echo "'tailf' requires 1 argument - parameter"
    return 
  fi
  case "${1}" in
    syslog)
      if [ -z "$SYSLOG" ]; then
        echo "warning: log file "$SYSLOG" does not exist!"
        return
      fi
      echo "type 'ctrl-c' to end"
      echo "tail -f $SYSLOG"
      tail -f $SYSLOG
      ;;
   *)
      echo "'tailf' supports the following parameters: 'syslog'" 
    ;;
  esac
}

# runs a fairly comprehensive set of Perl and Python scripts to validate
# that these environments are working as expected
verify() {
  echo +
  echo ++ Verifying Perl Environment:
  pushd $SCRIPTDIR > /dev/null 2>&1
  perl $SCRIPTDIR/cloud/general/t/verify-perl-modules.t
  for file in $(find . -name "*.pl"); do
    perl -c $file > /dev/null 2>&1 && echo ok $file || echo not ok $file;
  done
  python $SCRIPTDIR/cloud/general/t/verify-python-modules.py
  echo +
  echo ++ Verifying Python scripts can pass compile phase \(python -m py_compile\)
  for file in $(find . -name "*.py"); do
    python -m py_compile $file > /dev/null 2>&1 && echo ok     $file || echo not ok $file;
    # clean up potentially useful *.pyc (compiled python) files
    rm -f ${file}c
  done
  echo +
  echo ++ Regression Testing
  ANS=$(python $SCRIPTDIR/monitoring/FortCheck.py $SCRIPTDIR/cloud/general/t/test-data/fort.61.nc 2>&1)
  if [ "$ANS" == "100.00" ]; then
   echo "ok ./monitoring/FortCheck.py can read fort.61.nc"
  else
   echo "not ok ./monitoring/FortCheck.py can't read cloud/general/t/test-data/fort.61.nc"
  fi 
  echo +
  echo ++ Benchmarking and verifying netCDF4 module functionality
  rm -f ./*.nc # pre clean up
  pyNETCDFBENCH=$SCRIPTDIR/cloud/general/t/netcdf4-bench.py
  $pyNETCDFBENCH && echo ok $pyNETCDFBENCH works || echo not ok $pyNETCDFBENCH 
  rm -f ./*.nc # post clean up
  popd > /dev/null 2>&1
}

# todo - added to general 'verify' function once it's merged to master
verify_netcdf() {
  echo +
  echo ++ Verifying HDF5 and NetCDF tools and libraries
  for b in gif2h5 h52gif h5cc h5copy h5debug h5diff h5dump h5fc h5import h5jam h5ls h5mkgrp h5perf_serial h5redeploy h5repack h5repart h5stat h5unjam nc-config nccopy ncdump ncgen ncgen3 nf-config; do
    if [ -n "$(which $b 2> /dev/null)" ]; then
      echo "ok found '$b'"
    else
      echo "not ok, can't find '$b'"
    fi
  done
  for L in libhdf5.a libhdf5_fortran.a libhdf5_fortran.la libhdf5_fortran.so libhdf5_hl.a libhdf5hl_fortran.a libhdf5hl_fortran.la libhdf5hl_fortran.so libhdf5_hl.la libhdf5_hl.so libhdf5.la libhdf5.settings libhdf5.so libnetcdf.a libnetcdff.a libnetcdff.la libnetcdff.so libnetcdf.la libnetcdf.so pkgconfig; do
    if [ -e "$ASGS_INSTALL_PATH/lib/$L" ]; then
      echo "ok found '$L'"
    else
      echo "not ok, can't find '$L' in '$ASGS_INSTALL_PATH/lib'"
    fi
  done
}

purge() {
  if [ -z "${1}" ]; then
    echo "'purge' requires 1 argument - currently only supports 'rundir', 'scratchdir', 'statefile'."
    return 
  fi
  case "${1}" in
    rundir)
     read -p "This will delete the current run director, \"${RUNDIR}\". Type 'y' to proceed. [N] " DELETE_RUNDIR
     if [ 'y' == "${DELETE_RUNDIR}" ]; then
       rm -rvf "${RUNDIR}"
       RUNDIR=
     else
       echo "Purge of rundir cancelled."
     fi
    ;;
    statefile)
     read -p "This will delete the state file, \"${STATEFILE}\". Type 'y' to proceed. [N] " DELETE_STATEFILE
     if [ 'y' == "${DELETE_STATEFILE}" ]; then
       rm -rvf "${STATEFILE}"
       STATEFILE=
     else
       echo "Purge of state file cancelled."
     fi
    ;;
    scratchdir)
     read -p "This will delete EVERYTHING in the SCRATCH directory, \"${SCRATCH}\". Type 'y' to proceed. [N]? " DELETE_SCRATCH
     if [ 'y' == "${DELETE_SCRATCH}" ]; then
       rm -rvf ${SCRATCH}/*
     else
       echo "Purge of scratch directory cancelled."
     fi
    ;;
    *)
     echo "'${1}' is not supported. 'purge' currently only supports 'rundir', 'scratchdir', 'statefile'."
    ;;
  esac 
}

# initialization, do after bash functions have been loaded
export PS1='asgs (none)>'
echo
echo "Quick start:"
echo "  'initadcirc' to build and local register versions of ADCIRC"
echo "  'list profiles' to see what scenario package profiles exist"
echo "  'list adcirc' to see what builds of ADCIRC exist"
echo "  'load profile <profile_name>' to load saved profile"
echo "  'run' to initiated ASGS for loaded profile"
echo "  'help' for full list of options and features"
echo "  'goto scriptdir' to change current directory to ASGS' script directory"
echo "  'exit' to return to the login shell"
echo
echo "NOTE: This is a fully function bash shell environment; to update asgsh"
echo "or to recreate it, exit this shell and run asgs-brew.pl with the"
echo " --update-shell option"
echo

# handy aliases for the impatient
alias a="list adcirc"
alias c="edit config"
alias nukeit="purge scratchdir"
alias p="list profiles"
alias sd="goto scriptdir"
alias s="goto scratchdir"
alias v="verify"

# when started, ASGS Shell loads the 'default' profile, this can be made variable at some point
load profile ${profile-default}

# show important directories
show scriptdir
show scratchdir

# start off in $SCRIPTDIR
goto scriptdir

# provide a new line
echo

# temporary message, will be removed after a short while
echo "NOTE: The asgsh 'set' command has been replaced with 'define' because it is a built-in bash keyword. Type 'help' for more information."
