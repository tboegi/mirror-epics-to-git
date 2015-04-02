#!/bin/sh

LANG=C
LC_ALL=C
export LANG LC_ALL

me1=${0##*/}
shdir=${0%/*}

if ! type git-remote-hg >/dev/null 2>/dev/null; then
  if ! test -d git-remote-hg; then
    git clone https://github.com/tboegi/git-remote-hg.git
  fi &&
  if  test -d git-remote-hg; then
    ( cd git-remote-hg &&
        git checkout 91091f845ea5f87bbc2509625
     )
  fi &&
  if test "$me1" = "$shdir"; then
    shdir=.
  elif test -z "$shdir"; then
    shdir=.
  fi &&
  if test "$shdir" = .; then
    PATH=$PATH:$PWD/git-remote-hg
  else
    PATH=$PATH:$shdir/git-remote-hg
  fi
  export shdir PATH
fi &&

. ${shdir}/apt-yum-port.inc &&
. ${shdir}/which-directories.inc &&

epics4=$(echo pvCommonCPP pvDataCPP pvAccessCPP pvIOCCPP pvaSrv exampleCPP\
         pvDataJava pvDataJava pvAccessJava exampleJava easyPVAJava)

for d in $homeepicsgit homeepicshg $homeepicsgitepics4 $homeepicshgepics4; do
  mkdir -p $d || {
    echo >&2 mkdir -p $d failed
    exit 1
  }
done

addpacketifneeded python &&
addpacketifneeded hg mercurial &&

### epics4 via mercurial
(
  cd $homeepicshgepics4 && {
    for d in $epics4; do
      if  test -d "$d"; then
        (
          cd $d && {
            cmd=$(echo hg pull)
            echo PWD=$PWD cmd=$cmd
            eval "$cmd" || exit 1
          }
        )
      else
        cmd=$(echo hg clone http://epics-pvdata.hg.sourceforge.net:8000/hgroot/epics-pvdata/$d)
        echo PWD=$PWD cmd=$cmd
        eval $cmd
      fi
    done
  }
)


### epics4 via git-hg
addpacketifneeded python &&
addpacketifneeded hg mercurial &&
(
  cd $homeepicsgitepics4 && {
    for d in $epics4; do
      if  test -d "$d"; then
        (
          cd $d && {
            cmd=$(echo git fetch origin)
            echo PWD=$PWD cmd=$cmd
            eval "$cmd" || exit 1
            git checkout origin/master
          }
        )
      else
        cmd=$(echo git clone hg::http://hg.code.sf.net/p/epics-pvdata/$d)
        echo PWD=$PWD cmd=$cmd
        eval $cmd
      fi
    done
  }
)

