ARG NODE_VERSION=20.5.0
FROM node:${NODE_VERSION}-alpine

ENV NODE_ENV=production \
    PORT=3000

EXPOSE $PORT
RUN if [ -z "${PORT}" ] ; then echo "PORT not set!" ; exit 1; fi

ARG NON_ROOT_USER=indiekit
RUN if [ -z "${NON_ROOT_USER}" ] ; then echo "NON_ROOT_USER not set!" ; exit 1; fi && \
    addgroup -g 1234 indieweb && \
    adduser -u 1234 -G indieweb --shell /bin/ash --disabled-password $NON_ROOT_USER --home /home/$NON_ROOT_USER

USER $NON_ROOT_USER
WORKDIR /usr/src/app

COPY --chown=$NON_ROOT_USER:$NON_ROOT_USER package*.json ./
RUN npm ci

COPY --chown=$NON_ROOT_USER:$NON_ROOT_USER indiekit.config.js .

ENTRYPOINT ["node", "node_modules/@indiekit/indiekit/bin/cli.js", "--config", "indiekit.config.js"]
CMD ["serve"]
