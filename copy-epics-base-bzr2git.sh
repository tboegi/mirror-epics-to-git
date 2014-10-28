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


baseversions=$(echo epics-base epics-base/3.13 epics-base/3.14)
for d in $projectsepicsgitbase $projectsepicsbzrbase ; do
  mkdir -p $d || {
    echo mkdir -p $d failed
    exit 1
  }
done &&

if ! which bzr; then
  echo $APTGET bzr
  $APTGET bzr || {
		echo >&2 "Can not install bzr"
		echo >&2 "Aborting"
		exit 1
	}
fi &&

if ! test -d $projectsepicsbzrbase/.bzr; then
  (
    cd $projectsepicsbzrbase &&
    bzr init
  )
fi

for d in $baseversions
do
  d2=$(echo $d | sed -e 's!/!-!')
  if ! test -d $projectsepicsbzrbase/$d2; then
    (
      #clone bzr
      cd $projectsepicsbzrbase &&
      cmd=$(echo bzr clone lp:$d $d2)
      echo PWD=$PWD cmd=$cmd &&
      eval $cmd 2>&1 || {
        echo failed
      }
    )
  else
    (
      #pull bzr
      cd $projectsepicsbzrbase/$d2 &&
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
  cd $projectsepicsgitbase && {
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
				export GIT_TRACE=1
        cmd=$(echo git clone --mirror bzr::file:///$projectsepicsbzrbase/$d2 $d2.tmp.$$)
        echo PWD=$PWD cmd=$cmd
        eval "$cmd" 2>&1
        cmd= $(echo mv $d2.tmp.$$ $d2.git)
        echo PWD=$PWD cmd=$cmd
        eval $cmd 2>&1
      fi
    done
  }
)
