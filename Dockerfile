
FROM node:10.12.0-alpine

RUN mkdir /app
WORKDIR /app
ADD . .

ENV PATH="$PATH:./node_modules/.bin"
RUN cp -f .env.production .env && \
    apk add --update make bash && \
    make build-minify

ENTRYPOINT npm start || sleep 1000000

EXPOSE 4201

