
export PATH:=$(PATH):$(shell npm bin)
SHELL:=bash

ENVIRONMENT=$(shell if test -r .env && which jq >/dev/null 2>&1; then jq -r .environment .env; fi)
NEXT_VERSION=$(shell git tag | awk '{ sub(/^v/, ""); if (0 + $$1 > max) max = $$1; } END { print max + 0.1 }')
NEXT_TAG=v$(NEXT_VERSION)
CURRENT_VERSION=$(shell git describe --tags | sed -e 's/^v//')
CURRENT_TAG=$(shell git describe --tags)

JS_SOURCE=jssrc
ELM_SOURCE=src
DIST=dist
SERVICE_WORKER=$(DIST)/service-worker.js

GOOGLE_CLOUD_PREFIX=eu.gcr.io/proforto-team-sso
SERVERREGEX=[v]oting-booth
DOCKERNAME=voting-booth
DOCKERNET=voting-net
DOCKERPORTS=-p 4201:4201
.DEFAULT_GOAL:=help

##@ Generic:

# automatic self-documentation
help: ## display this help
	@awk 'BEGIN { FS = ":.*## "; tab = 19; color = "\033[36m"; indent = "  "; printf "\nUsage:\n  make " color "<target>\033[0m\n\nRecognized targets:\n" } /^[a-zA-Z0-9_-]+:.*?## / { pad = sprintf("\n%" tab "s" indent, "", $$2); gsub(/\\n/, pad); printf indent color "%-" tab "s\033[0m%s\n", $$1, $$2 } /^##@ / { gsub(/\\n/, "\n"); printf "\n%s\n", substr($$0, 5) } END { print "" }' $(MAKEFILE_LIST) # v1.42

##@ Webserver:

install: ## install all npm dependencies
	npm install

tag: ## create git tag, next in line (with 0.1 increments) and push to repo
	sed -i "" -E "s/^(var version = ')v[^']*(';)/\1$(NEXT_TAG)\2/" $(SERVICE_WORKER)
	sed -i "" -E 's/^(  "version": ")[^"]*(",)/\1$(NEXT_VERSION).0\2/' package.json
	git commit $(SERVICE_WORKER) package.json -m 'Updated files with new tag'
	git tag $(NEXT_TAG)
	make version
	git push
	git push --tags

rmtag: ## remove a tag erroneously created (current tag only)
	git push origin --delete $(CURRENT_TAG)
	git tag --delete $(CURRENT_TAG)

version: ## update the version file with the current git tag name
	echo "jQuery(document).ready(function () { jQuery('#version').prepend('$(CURRENT_TAG)'); });" > $(JS_SOURCE)/version.js

bump: ## increment the version in the serviceworker
	sed -i "" -E "s/^(var version = 'v[0-9.]*)';/\1.1';/" $(SERVICE_WORKER)

build: version ## compile elm files to JS; bundle and minify JS files
	elm-make $(ELM_SOURCE)/Main.elm --yes --output $(JS_SOURCE)/Elm.js
	browserify $(JS_SOURCE)/app.js -o $(JS_SOURCE)/bundle.js
	if [[ "$(ENVIRONMENT)" = development ]]; then                                     \
		cp $(JS_SOURCE)/bundle.js $(DIST)/bundle.js;                              \
	else                                                                              \
		uglifyjs $(JS_SOURCE)/bundle.js                                           \
			--compress "pure_funcs=['F2','F3','F4','F5','F6','F7','F8','F9']" \
			--mangle --output $(DIST)/bundle.js;                              \
	fi

start: build ## start the webserver
	npm start

stop: ## stop the webserver
	npm stop

status: ## show the webserver status
	@ps -ef | grep -s $(SERVERREGEX) || true

restart: stop start ## restart the webserver

watch: ## start the webserver. rebuild and restart if the source changes
	while make build && npm start & do                               \
		rm $(JS_SOURCE)/bundle.js.tmp-browserify-* 2>/dev/null;  \
		fswatch --one-event -e bundle.js -e Elm.js -e version.js \
			$(ELM_SOURCE) $(JS_SOURCE) tokenserver;          \
		echo 'Changes detected, rebuilding...';                  \
		npm stop;                                                \
	done

##@ Docker:

docker-status: ## show the status of the docker image and containers
	@echo IMAGES
	@docker images | grep $(DOCKERNAME) || echo none
	@echo CONTAINERS
	@docker ps -a  | grep $(DOCKERNAME) || echo none

docker-build: ## build the docker image
	docker build -t $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest .

docker-tag: ## tag the :latest docker image with the current version
	docker image tag $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):$(CURRENT_VERSION)

docker-push: ## push the current image tag to docker repo
	docker push $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):$(CURRENT_VERSION)

docker-start: ## start the docker container
	if docker ps -a | grep voting-booth >/dev/null 2>&1; then        \
		docker start $(DOCKERNAME);                              \
	else                                                             \
		docker run --name $(DOCKERNAME) $(DOCKERPORTS)           \
			-t $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest & \
	fi

docker-build-start: docker-build docker-start ## build the docker image and start a container

docker-stop: ## stop the docker container
	-docker stop $(DOCKERNAME)

docker-destroy: docker-stop ## destroy the docker image and container
	-docker rm -f $(DOCKERNAME)
	-docker rmi $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest

docker-shell: ## shell into the running docker container
	docker exec -it $(DOCKERNAME) /bin/bash

.PHONY: help install tag rmtag version bump build start stop status restart \
	docker-status docker-build docker-tag docker-push docker-start      \
	docker-build-start docker-stop docker-destroy docker-shell

