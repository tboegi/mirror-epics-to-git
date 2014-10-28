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

srcurl=subversion.xray.aps.anl.gov/synApps
projectX=xray.aps.anl.gov.synApps

localSVNmirror=~/projects/epics/upstream/localSVNmirrors/$srcurl
SVN=https://$srcurl

export localSVNmirror homeepicsgit SVN projectX

. $shdir/helper-xor-xray.sh
exit
