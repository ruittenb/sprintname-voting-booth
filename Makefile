DOCKERNAME=voting-booth
DOCKERNET=voting-net
DOCKERPORTS=-p 4201:4201
#NODE_PIDS=$$(/bin/ps -o user,pid,args -t `tty` | awk '$$3 ~ /[n]ode/ { print $$2 }')
NODE_PIDS=$$(lsof -l -n -i tcp | awk '/ \*:420[12] / { print $$2 }')

usage:
	@echo "Recognized targets:"
	@echo
	@echo "  make install : install all dependencies"
	@echo "  make start   : start the webserver"
	@echo "  make stop    : stop the webserver"
	@echo "  make restart : restart the webserver"
	@echo "  make version : write tag version to webroot file"
	@echo "  make status  : show webserver status"
	@echo
	@echo "  make docker-build      : build the docker image"
	@echo "  make docker-start      : start the docker container"
	@echo "  make docker-build-start: build and start the docker container"
	@echo "  make docker-stop       : stop the docker container"
	@echo "  make docker-status     : show docker container + image status"
	@echo "  make docker-shell      : shell into docker container"
	@echo "  make docker-destroy    : destroy docker container + image"
	@echo

install:
	npm install

version:
	echo "jQuery(document).ready(function () { jQuery('#version').prepend('$$(git describe --tags)'); });" > dist/version.js

status:
	@test "$(NODE_PIDS)" && echo Running || echo Stopped

start: version
	nf start

stop:
	-if [ "$(NODE_PIDS)" ]; then \
		kill -TERM $(NODE_PIDS) && sleep 1 && \
		kill -QUIT $(NODE_PIDS) && sleep 1 && \
		kill -KILL $(NODE_PIDS); \
	fi

restart: stop start

docker-status:
	-docker images | grep voting-booth
	-docker ps -a  | grep voting-booth

docker-build:
	docker build -t $(DOCKERNAME):latest .

docker-start:
	docker run --name $(DOCKERNAME) $(DOCKERPORTS) -t $(DOCKERNAME):latest &

docker-build-start: docker-build docker-start

docker-stop:
	docker stop $(DOCKERNAME)

docker-destroy: docker-stop
	-docker rm -f $(DOCKERNAME)
	-docker rmi $(DOCKERNAME):latest

docker-shell:
	docker exec -it $(DOCKERNAME) /bin/bash

.PHONY: usage install version status start stop restart \
	docker-status docker-build docker-start docker-build-start \
	docker-stop docker-destroy docker-shell
