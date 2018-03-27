FROM node:6.9.1

RUN	npm install -g npm  && \
	npm install -g yarn && \
	npm install -g elm  && \
	mkdir /app

WORKDIR /app
ADD . .

CMD ["sleep", "1000000"]
#CMD ["yarn", "start"]

EXPOSE 80

