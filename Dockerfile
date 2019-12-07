FROM ericdraken/browserless-chrome-base:armv7

# Application parameters and variables
ENV APP_DIR=/usr/src/app
ENV CONNECTION_TIMEOUT=60000
ENV ENABLE_XVBF=true
ENV HOST=0.0.0.0
ENV IS_DOCKER=true
ENV NODE_ENV=production
ENV PORT=3000
ENV WORKSPACE_DIR=$APP_DIR/workspace
ENV CHROMEDRIVER_SKIP_DOWNLOAD=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN mkdir -p $APP_DIR $WORKSPACE_DIR

WORKDIR $APP_DIR

# Install app dependencies
COPY package.json .
COPY tsconfig.json .
COPY . .

# Install Chrome Stable
RUN apt-get update && \
    apt-get -y install apt-utils chromium-browser && \
    apt-get -qq clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -s /usr/bin/chromium-browser /usr/bin/google-chrome

# Install Chrome driver
RUN wget -q https://github.com/electron/electron/releases/download/v7.1.3/chromedriver-v7.1.3-linux-armv7l.zip \
    -O /tmp/driver.zip && \
    unzip /tmp/driver.zip -d /tmp/ && \
    mv -f /tmp/chromedriver /usr/bin/ && \
    chmod +x /usr/bin/chromedriver

# Build
RUN npm install && \
    npm run post-install && \
    npm run build && \
    chown -R blessuser:blessuser $APP_DIR

# Run everything after as non-privileged user.
USER blessuser

# Expose the web-socket and HTTP ports
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD [ "node", "./build/index.js" ]
