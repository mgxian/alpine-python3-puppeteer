FROM node:9-alpine

# Installs latest Chromium (68) package.
RUN apk update && apk upgrade && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk add --no-cache \
      chromium@edge \
      nss@edge \
      freetype@edge \
      harfbuzz@edge

# Install Python 3
COPY requirements.txt requirements.txt
RUN apk add --no-cache --virtual .build-deps g++ make python3-dev libffi libffi-dev openssl-dev && \
    apk add --no-cache --update python3 ca-certificates && \
    pip3 install -r requirements.txt

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/

# Puppeteer v1.4.0 works with Chromium 68.
RUN yarn add puppeteer@1.4.0

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -g pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# PWD
WORKDIR /app

# Run everything after as non-privileged user.
USER pptruser
