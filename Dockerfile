
############################################################################
# builder

FROM node:14-alpine as builder

RUN mkdir /app
WORKDIR /app
COPY . .

ENV PATH="$PATH:./node_modules/.bin"
RUN apk add --update make bash && \
    make prod build-non-elm

############################################################################
# main

FROM mhart/alpine-node:14

WORKDIR /app
COPY --from=builder /app /app

EXPOSE 4201

#CMD [ "sleep", "1000000" ]
CMD [ "npm", "start" ]

