FROM python:3.6-alpine3.8
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-v2.6.1}
ARG URL=https://github.com/digitalocean/netbox/archive/$VERSION.tar.gz

RUN apk update \
  && apk add --no-cache \
      bash \
      build-base \
      ca-certificates \
      cyrus-sasl-dev \
      graphviz \
      ttf-ubuntu-font-family \
      jpeg-dev \
      libffi-dev \
      libxml2-dev \
      libxslt-dev \
      openldap-dev \
      postgresql-dev \
      wget \
  && pip install --upgrade pip \
  && pip install gunicorn napalm

WORKDIR /opt
RUN wget -q -O - "${URL}" | tar xz \
  && ln -s netbox* netbox

WORKDIR /opt/netbox
RUN pip install -r requirements.txt

COPY files/configuration.py /opt/netbox/netbox/netbox/configuration.py
COPY files/gunicorn_config.py /opt/netbox/
COPY files/nginx.conf /etc/netbox-nginx/nginx.conf
COPY files/run.sh /run.sh

WORKDIR /opt/netbox/netbox

ENTRYPOINT ["/run.sh"]
CMD ["gunicorn", "-c /opt/netbox/gunicorn_config.py", "netbox.wsgi"]

VOLUME ["/etc/netbox-nginx/"]
EXPOSE 8001
