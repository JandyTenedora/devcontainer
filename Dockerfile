FROM node:lts-alpine

ARG USER_UID=1000

RUN apk add --no-cache git shadow && \
    usermod -u ${USER_UID} node && \
    chown -R node:node /home/node

COPY askpass.sh /usr/local/bin/askpass
RUN chmod +x /usr/local/bin/askpass

RUN npm install -g @anthropic-ai/claude-code

USER node

CMD ["claude"]
