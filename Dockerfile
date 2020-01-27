FROM debian:buster
MAINTAINER Matt Bentley <mbentley@mbentley.net>

ARG ldap=false
ARG latex=false

RUN (apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential git python3 python3-dev python3-pip nginx sqlite3 tzdata gettext)
RUN (test ! "$ldap" = "true" || DEBIAN_FRONTEND=noninteractive apt-get install -y libsasl2-dev python3-dev libldap2-dev libssl-dev)
RUN (test ! "$latex" = "true" || DEBIAN_FRONTEND=noninteractive apt-get install -y texlive-latex-base texlive-latex-recommended texlive-fonts-recommended texlive-lang-german && \
  rm -rf /var/lib/apt/lists/*)
RUN (pip3 install uwsgi supervisor)

ADD app/requirements.txt /opt/django/app/requirements.txt
RUN pip3 install -r /opt/django/app/requirements.txt
ADD . /opt/django/

RUN (echo "daemon off;" >> /etc/nginx/nginx.conf &&\
  rm /etc/nginx/sites-enabled/default &&\
  ln -s /opt/django/django.conf /etc/nginx/sites-enabled/)

EXPOSE 80

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

CMD ["/opt/django/run.sh"]
