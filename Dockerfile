FROM node:lts-alpine

RUN apk add --no-cache git

COPY askpass.sh /usr/local/bin/askpass
RUN chmod +x /usr/local/bin/askpass

RUN npm install -g @anthropic-ai/claude-code

USER node

CMD ["claude"]
