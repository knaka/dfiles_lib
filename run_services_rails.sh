#!/bin/sh

initializing() { ! test -e /initialized; }
if (test -n "$USER_UID" && test "$USER_UID" != $(id -u unpriv)) ||
 (test -n "$USER_GID" && test "$USER_GID" != $(id -g unpriv))
then
  # These run in background.
  deluser unpriv
  chown -R $USER_UID:$USER_GID /home/unpriv/
  # $USER_GID can be reserved already.
  groupadd -g $USER_GID unpriv
  adduser --uid $USER_UID --gid $USER_GID --disabled-password --gecos "" unpriv < /dev/null
fi
cd /home/unpriv/
appname=appapp
if ! test -r "$appname"/Gemfile
then
  rsync -ar $appname.bak/ "$appname"
fi
if test -n "$TIMEZONE"
then
  echo "$TIMEZONE" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata
fi
initializing && FORCE=true run-bundle install
test -r /run_services_prj.sh && source /run_services_prj.sh
touch /initialized
