FROM ubuntu:22.04 AS base

ARG ADMIN_EMAIL \
    BUILD_DATE \
    COMMIT_SHA \
    MAILHOST \
    VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    POSTFIX_VERSION=3.8.0

LABEL org.opencontainers.image.authors="Tiffany Huang <hello@tifa.io>" \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.url="https://github.com/tifa/virtualmail" \
      org.opencontainers.image.documentation="https://tifa.github.io/virtualmail" \
      org.opencontainers.image.description="Send and receive emails through virtual aliases." \
      org.opencontainers.image.revision=${COMMIT_SHA} \
      org.opencontainers.image.vendor="Tiffany Huang"

# Add repositories
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        software-properties-common \
    # Ansible
    && apt-get update \
    && apt-add-repository ppa:ansible/ansible \
    && apt-get remove -y software-properties-common \
    && apt-get install -y --no-install-recommends \
        ansible \
        apache2 \
        certbot \
        cron \
        dnsutils \
        dovecot-lmtpd \
        dovecot-sqlite \
        fail2ban \
        gcc \
        less \
        libdb-dev \
        libsqlite3-dev \
        m4 \
        mailutils \
        make \
        opendkim \
        opendkim-tools \
        pflogsumm \
        postfix-policyd-spf-python \
        postfix-sqlite \
        python3-certbot-apache \
        rsyslog \
        sqlite3 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y

WORKDIR /virtualmail/provision/


FROM base as dev

LABEL org.opencontainers.image.version="${VERSION}-dev"

ENTRYPOINT [ "/bin/bash" ]


FROM base as prod

LABEL org.opencontainers.image.version="${VERSION}"

COPY ./provision/ /virtualmail/provision/

RUN make base
