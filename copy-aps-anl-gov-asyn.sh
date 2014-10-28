#!/bin/sh

LANG=C
LC_ALL=C
export LANG LC_ALL

me1=${0##*/}
shdir=${0%/*}

if test "$me1" = "$shdir"; then
  shdir=.
elif test -z "$shdir"; then
  shdir=.
fi &&
if test "$shdir" = .; then
  PATH=$PWD:$PATH
else
  PATH=$shdir:$PATH
fi

export shdir PATH &&

. ${shdir}/apt-yum-port.inc &&
. ${shdir}/which-directories.inc &&


srcurl=svn.aps.anl.gov/epics/asyn
projectX=aps.anl.gov.epics_asyn

localSVNmirror=$localSVNmirrors/$srcurl
SVN=https://$srcurl

export localSVNmirror homeepicsgit SVN projectX

. $shdir/helper-one-svn-one-git.sh 
exit
