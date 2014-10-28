#Include file to find out how to install a package
# We do an auto-probing:
# Mac OS X:       port install
# Debian:         apt-get
# Scientif Linux: yum install



#apt or yum or port
if uname -a | egrep "CYGWIN|MING" >/dev/null; then
  SUDO=
else
  SUDO=sudo
fi &&

APTGET=/bin/false
if type apt-get >/dev/null 2>/dev/null; then
  APTGET="$SUDO apt-get install"
fi
if type yum >/dev/null 2>/dev/null; then
  APTGET="$SUDO /usr/bin/yum install"
fi
# port (Mac Ports)
if test -x /opt/local/bin/port; then
  APTGET="$SUDO port install"
fi
export APTGET

# Shell function: add package x when y is not there
addpacketifneeded() {
  needed=$1
  tobeinstalled=$2
  if test -z "$tobeinstalled"; then
    tobeinstalled=$needed
  fi &&
  if ! which $needed >/dev/null ; then
    echo $APTGET install $tobeinstalled &&
    $SUDO $APTGET $tobeinstalled
  fi
}



