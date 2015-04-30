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

echo checking bzr git-remote-bzr &&
addpacketifneeded bzr &&
which git-remote-bzr || {
  echo git-remote-bzr not found
  echo PATH=$PATH
  exit 1
}

baseversions=$(echo epics-base epics-base/3.13 epics-base/3.14 epics-base/3.15 epics-base/3.16)
export baseversions
for d in $homeepicsgitbase $homeepicsbzrbase ; do
  mkdir -p $d || {
    echo mkdir -p $d failed
    exit 1
  }
done &&

if ! test -d $homeepicsbzrbase/.bzr; then
  (
    cd $homeepicsbzrbase &&
    bzr init
  )
fi

echo LINENO=$LINENO PWD=$PWD baseversions=$baseversions &&

for d in $baseversions
do
  d2=$(echo $d | sed -e 's!/!-!')
  echo LINENO=$LINENO PWD=$PWD d2=$d2 &&
  if ! test -d $homeepicsbzrbase/$d2; then
    (
      #clone bzr
      echo LINENO=$LINENO PWD=$PWD &&
      cd $homeepicsbzrbase &&
      echo LINENO=$LINENO PWD=$PWD &&
      cmd=$(echo bzr clone lp:$d $d2)
      echo PWD=$PWD cmd=$cmd &&
      eval $cmd 2>&1 || {
        echo failed
      }
    )
  else
    (
      #pull bzr
      cd $homeepicsbzrbase/$d2 &&
      cmd=$(echo bzr pull)
      echo PWD=$PWD cmd=$cmd &&
      eval $cmd 2>&1 || {
        echo failed
      }
    )
  fi
done

### epics-base via bazaar
(
  cd $homeepicsgitbase && {
    for d in $baseversions
    do
      d2=$(echo $d | sed -e 's!/!-!')
      if test -d $d2.git; then
        (
          cd $d2.git && {
            cmd=$(echo git fetch origin)
            echo PWD=$PWD PATH=$PATH cmd=$cmd
            eval "$cmd" 2>&1
          }
        )
      else
        cmd=$(echo git clone --mirror bzr::file:///$homeepicsbzrbase/$d2 $d2.tmp.$$)
        echo PWD=$PWD cmd=$cmd
        eval "$cmd" 2>&1
        cmd= $(echo mv $d2.tmp.$$ $d2.git)
        echo PWD=$PWD cmd=$cmd
        eval $cmd 2>&1
      fi
    done
  }
)
