
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
      addpacketifneeded libsvn-perl ||
      addpacketifneeded git-svn ||
      exit 1
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
    dirs=$(echo $dir1/* | sort)
    echo LINENO=$LINENO PWD=$PWD dirs=$dirs
    singlesvn=$(echo $dir1/branches $dir1/tags $dir1/trunk)
    echo LINENO=$LINENO PWD=$PWD singlesvn=$singlesvn
    if test "$dirs" = "$singlesvn"; then
      echo LINENO=$LINENO PWD=$PWD singlesvn=dirs
      dirs=.
    fi
    for i in $dirs; do
      subdir=$(echo $i | sed -e "s!.*/!!g")
      echo LINENO=$LINENO PWD=$PWD subdir=$subdir
      if test "$subdir" = "*"; then
        echo "PWD=$PWD", can not continue
        echo "dir1=$dir1", can not continue
        echo "PWD/dir1=$PWD/$dir1", can not continue
        echo "subdir=$subdir", can not continue
        exit 1
      fi &&
      locallocalSVNmirror=$(echo $localSVNmirror | sed -e "s%^$HOME%~%") &&
      echo locallocalSVNmirror="$locallocalSVNmirror" &&
      if ! test -d "$subdir/.git"; then
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
          cd $subdir &&
          cmd=$(echo git svn fetch)
          echo LINENO=$LINENO PWD=$PWD cmd=$cmd
          eval "$cmd" || exit 1
          cmd=$(echo git checkout remotes/origin/trunk)
          echo LINENO=$LINENO PWD=$PWD cmd=$cmd
          eval "$cmd" || exit 1
        )
      fi
    done
  )
)
