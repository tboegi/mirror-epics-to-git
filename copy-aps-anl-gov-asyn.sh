#!/bin/sh

LANG=C
LC_ALL=C
export LANG LC_ALL

me1=${0##*/}
father=${0%/*}

if test "$me1" = "$father"; then
  father=.
elif test -z "$father"; then
  father=.
fi &&
if test "$father" = .; then
	PATH=$PWD:$PATH
else
	PATH=$father:$PATH
fi

#echo LINENO=$LINENO me1=$me1
#echo LINENO=$LINENO father=$father
#echo LINENO=$LINENO PATH=$PATH

export father PATH &&

which git-remote-bzr &&

. ${father}/apt-yum-port.inc &&
. ${father}/which-directories.inc &&


##projectsepicsgit=~/projects/epics/upstream/git

srcurl=svn.aps.anl.gov/epics/asyn
projectX=aps.anl.gov.epics_asyn

localSVNmirror=$localSVNmirrors/$srcurl
SVN=https://$srcurl

export localSVNmirror projectsepicsgit SVN projectX

. $father/helper-one-svn-one-git.sh 
exit
