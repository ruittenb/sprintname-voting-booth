DOCKERNAME=voting-booth
DOCKERNET=voting-net
DOCKERPORTS=-p 4201:4201 -p 4202:4202
NODE_PIDS=$$(/bin/ps -o user,pid,args -t `tty` | awk '$$3 ~ /[n]ode/ { print $$2 }')

status:
	@test "$(NODE_PIDS)" && echo Running || echo Stopped

build:
	webpack

start:
	webpack-dev-server

stop:
	if [ "$(NODE_PIDS)" ]; then \
		kill -TERM $(NODE_PIDS) && sleep 1 && \
		kill -QUIT $(NODE_PIDS) && sleep 1 && \
		kill -KILL $(NODE_PIDS); \
	fi

restart:
	make stop
	make start

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

.PHONY: status start stop restart \
	docker-status docker-build docker-start docker-build-start \
	docker-stop docker-destroy docker-shell
