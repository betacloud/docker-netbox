FROM python:2.7-alpine
MAINTAINER Betacloud Solutions GmbH (https://www.betacloud-solutions.de)

ARG VERSION
ENV VERSION ${VERSION:-v2.0.7}
ARG URL=https://github.com/digitalocean/netbox/archive/$VERSION.tar.gz

RUN apk add --no-cache \
      bash \
      build-base \
      ca-certificates \
      cyrus-sasl-dev \
      graphviz \
      jpeg-dev \
      libffi-dev \
      libxml2-dev \
      libxslt-dev \
      openldap-dev \
      openssl-dev \
      postgresql-dev \
      wget \
  && pip install --upgrade pip \
  && pip install gunicorn==17.5 django-auth-ldap

WORKDIR /opt
RUN wget -q -O - "${URL}" | tar xz \
  && ln -s netbox* netbox

WORKDIR /opt/netbox
RUN pip install -r requirements.txt \
  && ln -s configuration.docker.py netbox/netbox/configuration.py

COPY files/gunicorn_config.py /opt/netbox/
COPY files/run.sh /run.sh
COPY files/nginx.conf /etc/netbox-nginx/nginx.conf

ENTRYPOINT ["/run.sh"]

VOLUME ["/etc/netbox-nginx/"]
EXPOSE 8001
