FROM node:10.12.0

RUN mkdir /app
WORKDIR /app
ADD . .

ENV PATH="$PATH:./node_modules/.bin"
RUN make install build
ENTRYPOINT npm start || sleep 1000000

EXPOSE 4201

