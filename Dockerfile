FROM node:6.9.1

RUN mkdir /app
WORKDIR /app
ADD . .

RUN npm uninstall --save fsevents && \
    npm install -g yarn  && \
    yarn install

ENTRYPOINT yarn start || sleep 1000000

EXPOSE 4201

