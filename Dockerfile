FROM python:2.7-alpine

ARG BRANCH=v2.0.7
ARG URL=https://github.com/digitalocean/netbox/archive/$BRANCH.tar.gz

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
  && pip install gunicorn==17.5 django-auth-ldap

WORKDIR /opt
RUN wget -q -O - "${URL}" | tar xz \
  && ln -s netbox* netbox

WORKDIR /opt/netbox
RUN pip install -r requirements.txt \
  && ln -s configuration.docker.py netbox/netbox/configuration.py

COPY docker/gunicorn_config.py /opt/netbox/
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
COPY docker/nginx.conf /etc/netbox-nginx/nginx.conf

ENTRYPOINT [ "/docker-entrypoint.sh" ]

VOLUME ["/etc/netbox-nginx/"]
EXPOSE 8001
