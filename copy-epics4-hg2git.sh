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

which git-remote-hg &&

. ${father}/apt-yum-port.inc &&
. ${father}/which-directories.inc &&

epics4=$(echo pvCommonCPP pvDataCPP pvAccessCPP pvIOCCPP pvaSrv exampleCPP\
         pvDataJava pvDataJava pvAccessJava exampleJava easyPVAJava)

for d in $projectsepicsgit projectsepicshg $projectsepicsgitepics4 $projectsepicshgepics4; do
  mkdir -p $d || {
    echo >&2 mkdir -p $d failed
    exit 1
  }
done

addpacketifneeded python
addpacketifneeded hg mercurial

### epics4 via mercurial
(
  cd $projectsepicshgepics4 && {
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
  cd $projectsepicsgitepics4 && {
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

