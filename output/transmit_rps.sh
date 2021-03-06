#!/bin/bash
#------------------------------------------------------------------------
# transmit_rps.sh: transmits run.properties to run properties database.
#------------------------------------------------------------------------
# Copyright(C) 2015--2019 Jason Fleming
#
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
#------------------------------------------------------------------------
#
THIS="output/transmit_rps.sh"
#
declare -A properties
SCENARIODIR=$PWD
RUNPROPERTIES=$SCENARIODIR/run.properties
if [[ $# -eq 1 ]]; then
   RUNPROPERTIES=$1
   SCENARIODIR=`dirname $RUNPROPERTIES`
fi
# this script can be called with just one command line option: the
# full path to the run.properties file
echo "Loading properties."
# get loadProperties function
SCRIPTDIR=`sed -n 's/[ ^]*$//;s/path.scriptdir\s*:\s*//p' $RUNPROPERTIES`
source $SCRIPTDIR/properties.sh
# load run.properties file into associative array
loadProperties $RUNPROPERTIES
source $SCRIPTDIR/monitoring/logging.sh
source $SCRIPTDIR/platforms.sh

export SYSLOG=${properties['monitoring.logging.file.syslog']}
export RMQMessaging_Script_RP=${properties['monitoring.rmqmessaging.scriptrp']}
export RMQMessaging_LocationName=${properties['monitoring.rmqmessaging.locationname']}
export RMQMessaging_Transmit=${properties['monitoring.rmqmessaging.transmit']}
export INSTANCENAME=${properties['instancename']}

# get the parent uid
ppid=`ps -o ppid $$ | sed '1d'|  sed -r 's/^ *//g'`

# RMQMessageRunProp is in monitoring/logging.sh
RMQMessageRunProp "$SCENARIODIR"  "$ppid"

if [ $? == 0 ] ; then
        date > rps.transmitted
else
        touch rps.transmit.failed
fi

