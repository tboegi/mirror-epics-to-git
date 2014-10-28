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

epics4=$(echo pvCommonCPP pvDataCPP pvAccessCPP pvIOCCPP pvaSrv exampleCPP\
         pvDataJava pvDataJava pvAccessJava exampleJava easyPVAJava)

for d in $homeepicsgit homeepicshg $homeepicsgitepics4 $homeepicshgepics4; do
  mkdir -p $d || {
    echo >&2 mkdir -p $d failed
    exit 1
  }
done

addpacketifneeded python
addpacketifneeded hg mercurial

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

