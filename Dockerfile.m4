changequote([[, ]])
define([[concat]], [[$1$2]])dnl

# --------------------------------------------------------------------

FROM phusion/baseimage:latest
MAINTAINER Kiichiro NAKA <knaka@ayutaya.com>

ENV HOME /root/
WORKDIR $HOME

# --------------------------------------------------------------------
# Platform

RUN apt-get update

# gosu(8) would be necessary for all cases.
RUN apt-get install -y curl
RUN curl -o /usr/local/bin/gosu -sSL \
     "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" && \
     chmod +x /usr/local/bin/gosu

# Unprivileged user to run original services
RUN adduser --disabled-password --gecos "" unpriv

sinclude([[dfiles_copy/Dockerfile-pre.m4]])

# --------------------------------------------------------------------

include(Dockerfile-FRAMEWORK.m4)

# --------------------------------------------------------------------
# Supplemental Files.

RUN chown -R unpriv:unpriv /home/unpriv/

ADD concat(run_services_, FRAMEWORK).sh /etc/my_init.d/00_run_services.sh
RUN chmod +x /etc/my_init.d/00_run_services.sh

ENV S /usr/local/bin/run-bundle
COPY run-bundle $S
RUN chmod +x $S

ADD dfiles_copy/run_services_prj.sh /run_services_prj.sh

# --------------------------------------------------------------------

sinclude([[dfiles_copy/Dockerfile-post.m4]])

ifdef([[DEVEL]], [[]], [[
	RUN apt-get clean && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*
]])
