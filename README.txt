What is this about ?
  To mirror EPICS to Git.
  This project allows different EPICS code bases to mirrored into Git
  repositories.

Why ?
  Sometimes you do not have an internet connection, but you want
  to look at the changelog of a file.
  If that file is under subversion, this is not possible.

Where?
  The default is to store them ~/epics/upstream:

What ?
- Asyn from svn.aps.anl.gov/epics/asyn
- Synapps from subversion.xray.aps.anl.gov/synApps
- EPICS base
- EPICS 4 (with restrictions, see below)



How does it work ?
For each VCS (subversion, bazaar, mercurial) a local copy is made first.
The local copy is done with the "native" tool.
The conversion to Git is done from this local copy.

This is to improve the reliablility of the conversion

Does the script suppport incremental updates ?
Yes. Once run, only the new "commits" are fetched in the next run.

Which platforms are supported ?
Subversion:
  The conversion from subversion into Git is supported "native" by Git.
  Unless you compile Git yourself, you probably use Git from your distribution.
  Not all distributions install git-svn, and the script tries to detect
  when the package is missing and installs the missing packages.
  This should work for Debian, Scientific Linux 6.5 and Ubuntu.
  Under Mac OS I typically compile Git myself.

Bazaar:
  You need to install bazaar yourself, the script does not do that.
  And you need to install python.
  To be more exact python2, as bazaar is written in python2.
  To convert from bazaar we use the git-remote-bzr package from
  https://github.com/felipec/git-remote-bzr.
  This is a python script, and it is included here,
  The conversion should work under Debian, Scientific Linux 6.5 and Ubuntu.
  I have tested it under different Mac OS X machines.
  On most of them I used Macports to install bzr, on one Fink.

Mercurial:
  You need to have Git, python2, mercurial, the python bindings for mercurial.
  Then we use the git-remote-hg package from
  https://github.com/felipec/git-remote-bzr.
  This is a python script, and it is included here.
  The conversion should work under Scientific Linux 6.5 and Ubuntu.
  Under Mac OS X the recent version of Mac Ports installed mercurial 3.2,
  which is not compatible with the conversion script.
  https://github.com/felipec/git-remote-hg/issues/27

  I have one machine which has Mercurial 2.7.1 installed from Fink where
  the conversion works.
  But I haven't managed to get it working on a freshly installed Mac OS X.
  Under Linux I sometimes have managed to install python2, mercurial 2.9
  and the python bindings from source (under /usr/local/bin), but that
  didn't work under Mac OS X so far.

  As mercurial and Git are quite similar, this conversion is more a
  low priority hobby.

  Another way may be to export from mercurial to Git, see
  http://repo.or.cz/w/fast-export.git
