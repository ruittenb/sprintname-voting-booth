#FROM node:10.12.0
FROM node:10.12.0-alpine

RUN mkdir /app
WORKDIR /app
ADD . .

#ENV PATH="$PATH:./node_modules/.bin"
RUN	rm -rf .env .git && \
	mv .env.production .env && \
	apt-get purge -y x11-common && \
	apt-get purge -y subversion && \
	apt-get purge -y perl python python-minimal python2.7 python2.7-minimal && \
	apt-get autoremove -y && \
	make install build

ENTRYPOINT npm start || sleep 1000000

EXPOSE 4201

