DOCKERNAME=voting-booth
DOCKERNET=voting-net
DOCKERPORTS=-p 4201:4201
#NODE_PIDS=$(shell /bin/ps -o user,pid,args -t `tty` | awk '$$3 ~ /[n]ode/ { print $$2 }')
NODE_PIDS=$(shell lsof -l -n -i tcp | awk '/ \*:420[12] / { print $$2 }')
NODE_PROCS=$(shell lsof -l -n -i tcp | awk '/ \*:420[12] / { print "-p " $$2 }')

##@ Generic:

# automatic self-documentation
.DEFAULT_GOAL:=help

help: ## display this help
	@awk 'BEGIN { FS = ":.*## "; tab = 19; color = "\033[36m"; indent = "  "; printf "\nUsage:\n  make " color "<target>\033[0m\n\nRecognized targets:\n" } /^[a-zA-Z0-9_-]+:.*?## / { pad = sprintf("\n%" tab "s" indent, "", $$2); gsub(/\\n/, pad); printf indent color "%-" tab "s\033[0m%s\n", $$1, $$2 } /^##@ / { gsub(/\\n/, "\n"); printf "\n%s\n", substr($$0, 5) } END { print "" }' $(MAKEFILE_LIST) # v1.42

##@ Webserver:

install: ## install all npm dependencies
	npm install

version: ## update the version file with the current git tag name
	echo "jQuery(document).ready(function () { jQuery('#version').prepend('$$(git describe --tags)'); });" > dist/version.js

status: ## show the webserver status
	@if [ "$(NODE_PIDS)" ]; then ps $(NODE_PROCS); fi | awk ' \
		/tokenserver/     { t=1 }  \
		/webpack.*server/ { w=1 }  \
		END {                      \
		    print "Webserver   is " (w ? "running" : "stopped"); \
		    print "Tokenserver is " (t ? "running" : "stopped"); \
		}'

start: version ## start the webserver
	nf start

stop: ## stop the webserver
	-if [ "$(NODE_PIDS)" ]; then \
		kill -TERM $(NODE_PIDS) && sleep 1 && \
		kill -QUIT $(NODE_PIDS) && sleep 1 && \
		kill -KILL $(NODE_PIDS); \
	fi

restart: stop start ## restart the webserver

##@ Docker:

docker-status: ## show the status of the docker image and containers
	@echo IMAGES
	@docker images | grep $(DOCKERNAME) || echo none
	@echo CONTAINERS
	@docker ps -a  | grep $(DOCKERNAME) || echo none

docker-build: ## build the docker image
	docker build -t $(DOCKERNAME):latest .

docker-start: ## start the docker container
	docker run --name $(DOCKERNAME) $(DOCKERPORTS) -t $(DOCKERNAME):latest &

docker-build-start: docker-build docker-start ## build the docker image and start a container

docker-stop: ## stop the docker container
	-docker stop $(DOCKERNAME)

docker-destroy: docker-stop ## destroy the docker image and container
	-docker rm -f $(DOCKERNAME)
	-docker rmi $(DOCKERNAME):latest

docker-shell: ## shell into the running docker container
	docker exec -it $(DOCKERNAME) /bin/bash

.PHONY: help install version status start stop restart \
	docker-status docker-build docker-start docker-build-start \
	docker-stop docker-destroy docker-shell

