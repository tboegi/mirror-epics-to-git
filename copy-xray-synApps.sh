#!/bin/sh

me1=${0##*/}
echo me1=$me1
if test -z "$father"; then 
  father=${0%/*}
  export father
fi
if test -z "$father"; then
  father=.
fi
echo father=$father
echo me1=$me1 logfile=$logfile
if test -n "$debug" && test -z "$logfile"; then
  logfile=$(date "+%y-%m-%d_%H.%M.%S")
  logfile=$(echo /tmp/$logfile.$me1)
  export logfile
  echo me1=$me1 logfile=$logfile
  eval "$0" "$@" | tee "$logfile"
  exit
else
  echo me1=$me1 no logfile
fi


projectsepicsgit=~/projects/epics/upstream/git

srcurl=subversion.xray.aps.anl.gov/synApps
projectX=xray.aps.anl.gov.synApps

localSVNmirror=~/projects/epics/upstream/localSVNmirrors/$srcurl
SVN=https://$srcurl

export localSVNmirror projectsepicsgit SVN projectX

. $father/helper-xor-xray.sh
exit
