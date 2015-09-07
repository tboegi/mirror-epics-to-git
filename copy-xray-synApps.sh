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

localSVNmirror=$localSVNmirrors/$srcurl
SVN=https://$srcurl
echo localSVNmirror=$localSVNmirror

export localSVNmirror homeepicsgit SVN projectX


addpacketifneeded svn subversion &&
addpacketifneeded svnadmin subversion &&

(
  if ! test -d $localSVNmirror; then
    mkdir -p $localSVNmirror
  fi &&
  cd $localSVNmirror && {
    if ! test -f format; then
      cmd=$(echo svnadmin create $PWD)
      echo LINENO=$LINENO PWD=$PWD cmd=$cmd
      eval $cmd 2>&1
      echo "#!/bin/sh" >hooks/pre-revprop-change &&
      echo "exit 0" >>hooks/pre-revprop-change &&
      chmod ugo+rx hooks/pre-revprop-change
      cmd=$(echo svnsync initialize file://$PWD $SVN)
      echo LINENO=$LINENO PWD=$PWD cmd=$cmd
      eval $cmd 2>&1
    fi
  } &&
  (
    cd $localSVNmirror && {
      srcuuid=$(svn info "$SVN" | grep "Repository UUID" | sed -e "s/Repository UUID: //g") &&
      echo srcuuid=$srcuuid &&
      dstuuid=$(svn info file://$PWD | grep "Repository UUID" | sed -e "s/Repository UUID: //g") &&
      echo dstuuid=$dstuuid &&
      if test $srcuuid != $dstuuid; then
        cmd=$(echo svnadmin setuuid $PWD $srcuuid) &&
        echo LINENO=$LINENO PWD=$PWD cmd=$cmd &&
        eval "$cmd"
      fi &&
      cmd=$(echo svnsync sync file://$PWD $SVN)
      echo LINENO=$LINENO PWD=$PWD cmd=$cmd
      eval $cmd 2>&1 || {
        cmd=$(echo svnsync sync file://$PWD)
        echo LINENO=$LINENO PWD=$PWD cmd=$cmd
        eval $cmd 2>&1
      }
    }
  )
)

#### git clone via local suberversion mirror
(
  mkdir -p "$homeepicsgit" &&
  cd $homeepicsgit || {
    echo >&2 cd $homeepicsgit failed
    exit 1
  }

  dir1=$PWD/../svn/${projectX}AllInOne
  if test -d "$dir1"; then
    if test $(echo dir1/*) = "dir1/*"; then
      echo PWD=$PWD dir1=$dir is empty &&
      rm -rf "$dir1/.git" && rmdir "$dir1"
    fi
  fi &&
  if ! test -e "$dir1"; then
    cmd=$(echo git svn clone file://$localSVNmirror $dir1)
    echo LINENO=$LINENO PWD=$PWD cmd=$cmd
    eval $cmd 2>&1 || {
      addpacketifneeded libsvn-perl
      addpacketifneeded git-svn
      eval $cmd
    }
  fi
  
  dir2=${projectX}
  echo dir2=$dir2
  echo localSVNmirror=$localSVNmirror
  mkdir -p $dir2 || {
    echo >&2 "Can not create $dir2"
    exit 1
  }
  
  (
    echo dir1=$dir1
    cd $dir2 &&
    for i in $dir1/*; do
      subdir=$(echo $i | sed -e "s!.*/!!g")
      echo LINENO=$LINENO PWD=$PWD subdir=$subdir
      if test "$subdir" = "*"; then
        echo "PWD=$PWD", can not continue
        echo "dir1=$dir1", can not continue
        echo "PWD/dir1=$PWD/$dir1", can not continue
        echo "subdir=$subdir", can not continue
        exit 1
      fi &&
      ###########################################
      # only motor !
      if ! test $subdir = motor; then
        continue
      fi
      locallocalSVNmirror=$(echo $localSVNmirror | sed -e "s%^$HOME%~%") &&
      echo locallocalSVNmirror="$locallocalSVNmirror" &&
      if ! test -d "$subdir"; then
        (
          cmd=$(echo git svn init \
            -T trunk -b branches -t tags \
            --prefix=origin/ \
            --rewrite-root="file://.../$dir2" \
            file://$localSVNmirror/$subdir $subdir)
          echo LINENO=$LINENO PWD=$PWD cmd=$cmd
          eval $cmd 2>&1
        )
      fi || mv  "$subdir" $$
      if test -d "$subdir"; then
        (
          pfx=origin/tags/
          cd $subdir &&
          # fetch
          cmd=$(echo git svn fetch)
          echo LINENO=$LINENO PWD=$PWD cmd=$cmd
          eval "$cmd" || exit 1
          # git clean/stash
          cmd=$(echo git clean -fd) &&
          echo LINENO=$LINENO PWD=$PWD cmd=$cmd &&
          eval "$cmd" || exit 1
          #
          if true; then
            tags=$(git branch -r | grep $pfx) &&
            for rtag in $tags; do
              ltag=$(echo $rtag | sed -e "s%$pfx%%g") &&
              if (git tag | grep "^$ltag\$"); then
                echo ltag=$ltag exists
                continue
              fi
              echo ltag=$ltag is new
              # git clean
              cmd=$(echo git clean -fd) &&
              echo LINENO=$LINENO PWD=$PWD cmd=$cmd &&
              eval "$cmd" || exit 1
              # git stash
              cmd=$(echo git stash) &&
              echo LINENO=$LINENO PWD=$PWD cmd=$cmd &&
              eval "$cmd" || exit 1
              #checkout rtag
              cmd=$(echo git checkout $rtag) &&
              echo LINENO=$LINENO PWD=$PWD cmd=$cmd &&
              eval "$cmd" || exit 1
              #tag it
              cmd=$(echo git tag -f $ltag) &&
              echo LINENO=$LINENO PWD=$PWD cmd=$cmd &&
              eval "$cmd" || exit 1
            done
          fi
          #
          cmd=$(echo git checkout remotes/origin/trunk)
          echo LINENO=$LINENO PWD=$PWD cmd=$cmd
          eval "$cmd" || exit 1
          remotes=$(git remote)
          if test -n "$remotes"; then
            for remote in $remotes; do
              echo remote=$remote
              cmd=$(echo git push --tags $remote origin/trunk:refs/heads/upstream-xray.aps.anl.gov.synApps)
              echo LINENO=$LINENO PWD=$PWD cmd=$cmd
              eval $cmd 2>&1
            done
          fi
        )
      fi
    done
  )
)
