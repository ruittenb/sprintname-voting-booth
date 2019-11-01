
FROM node:10.12.0-alpine

RUN mkdir /app
WORKDIR /app
ADD . .

ENV PATH="$PATH:./node_modules/.bin"
RUN apk add --update make bash && \
    make prod build-bundle build-js-minify-prod build-css-minify

ENTRYPOINT npm start # || sleep 1000000

EXPOSE 4201

