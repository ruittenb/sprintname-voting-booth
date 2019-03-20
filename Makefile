
export PATH:=$(PATH):$(shell npm bin)
SHELL:=bash

ENVIRONMENT=$(shell if test -r .env && which jq >/dev/null 2>&1; then jq -r .environment .env; fi)
NEXT_VERSION=$(shell git tag | awk '{ sub(/^v/, ""); if (0 + $$1 > max) max = $$1; } END { printf "%.1f", max + 0.1 }')
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
DOCKERPORTS=-p 4201:4201
KUBECONTEXT=voting-booth
.DEFAULT_GOAL:=help

############################################################################
##@ Generic:

# automatic self-documentation
.PHONY: help
help: ## display this help
	@awk 'BEGIN { FS = ":.*## "; tab = 19; color = "\033[36m"; indent = "  "; printf "\nUsage:\n  make " color "<target>\033[0m\n\nRecognized targets:\n" } /^[a-zA-Z0-9%_-]+:.*?## / { pad = sprintf("\n%" tab "s" indent, "", $$2); gsub(/\\n/, pad); printf indent color "%-" tab "s\033[0m%s\n", $$1, $$2 } /^##@ / { gsub(/\\n/, "\n"); printf "\n%s\n", substr($$0, 5) } END { print "" }' $(MAKEFILE_LIST) # v1.43

############################################################################
##@ Webserver:

.PHONY: install
install: ## install all npm dependencies
	npm install

.PHONY: build-elm
build-elm: ## compile elm files to javascript
	elm-make $(ELM_SOURCE)/Main.elm --yes --output $(JS_SOURCE)/Elm.js

.PHONY: build-bundle
build-bundle: ## bundle javascript files
	test "$(ENVIRONMENT)" = development &&                               \
		browserify $(JS_SOURCE)/app.js -o $(JS_SOURCE)/bundle.js ||  \
		browserify $(JS_SOURCE)/app.js                               \
			-g [ envify --NODE_ENV $${ENVIRONMENT:-production} ] \
			-g uglifyify -o $(JS_SOURCE)/bundle.js

.PHONY: build-do-minify
build-do-minify:
	uglifyjs $(JS_SOURCE)/bundle.js                                           \
		--compress "pure_funcs=['F2','F3','F4','F5','F6','F7','F8','F9']" \
		--mangle --output $(DIST)/bundle.js

.PHONY: build-minify
build-minify: ## minify javascript bundle (unless on development)
	test "$(ENVIRONMENT)" = development &&                 \
		cp $(JS_SOURCE)/bundle.js $(DIST)/bundle.js || \
		make build-do-minify

.PHONY: build
build: version build-elm build-bundle build-minify ## all of the build steps above

.PHONY: start
start: build ## start the webserver
	npm start

.PHONY: stop
stop: ## stop the webserver
	npm stop

.PHONY: status
status: ## show the webserver status
	@ps -ef | grep -s $(SERVERREGEX) || true

.PHONY: restart
restart: stop start ## restart the webserver

############################################################################
##@ Development:

.PHONY: version
version: ## update the version file with the current git tag name
	-which git >/dev/null 2>&1 \
		&& echo "jQuery(document).ready(function () { jQuery('#version').prepend('$(CURRENT_TAG)'); });" > $(JS_SOURCE)/version.js

.PHONY: prod
prod: ## mark environment as 'production'
	cp .env.production .env

.PHONY: devel
devel: ## mark environment as 'development'
	cp .env.development .env

.PHONY: bump
bump: ## increment the version in the serviceworker by 0.0.1
	perl -i'' -pe 's/^(var version = .v\d+\.\d\.)(\d+)(.;)/$$1 . ($$2 + 1) . $$3/e' $(SERVICE_WORKER)

.PHONY: show-err
show-err: # iTerm2 tab coloring
	@printf '\033]6;1;bg;red;brightness;128\a'
	@printf '\033]6;1;bg;green;brightness;0\a'

.PHONY: show-busy
show-busy: # iTerm2 tab coloring
	@printf '\033]6;1;bg;red;brightness;128\a'
	@printf '\033]6;1;bg;green;brightness;128\a'

.PHONY: show-ok
show-ok: # iTerm2 tab coloring
	@printf '\033]6;1;bg;red;brightness;0\a'
	@printf '\033]6;1;bg;green;brightness;128\a'

.PHONY: show-none
show-none: # iTerm2 tab coloring
	@printf '\033]6;1;bg;*;default\a'

.PHONY: watch
watch: ## start the webserver. rebuild and restart if the source changes
	(                                                                       \
		trap 'make show-none; exit' INT;                                \
		while make bump build && make show-ok || make show-err; do      \
			npm start &                                             \
			rm $(JS_SOURCE)/bundle.js.tmp-browserify-* 2>/dev/null; \
			fswatch --one-event $(ELM_SOURCE) $(JS_SOURCE)          \
				$(SERVICE_WORKER) tokenserver;                  \
			make show-busy;                                         \
			echo 'Changes detected, rebuilding...';                 \
			npm stop;                                               \
		done                                                            \
	)

.PHONY: tag
tag: ## create git tag, next in line (with 0.1 increments) and push to repo
	sed -i "" -E "s/^(var version = ')v[^']*(';)/\1$(NEXT_TAG).0\2/" $(SERVICE_WORKER)
	sed -i "" -E 's/^(  "version": ")[^"]*(",)/\1$(NEXT_VERSION).0\2/' package.json
	git commit $(SERVICE_WORKER) package.json -m 'Updated files with new tag'
	git tag $(NEXT_TAG)
	make version
	git push
	git push --tags

.PHONY: rmtag
rmtag: ## remove a tag erroneously created (current tag only)
	git push origin --delete $(CURRENT_TAG)
	git tag --delete $(CURRENT_TAG)

############################################################################
##@ Docker:

.PHONY: select-kube-context
select-kube-context:
	kubectl config use-context $(KUBECONTEXT)

.PHONY: docker-status
docker-status: ## show the status of the docker image and containers
	@echo IMAGES
	@docker images | grep $(DOCKERNAME) || echo none
	@echo CONTAINERS
	@docker ps -a  | grep $(DOCKERNAME) || echo none

.PHONY: docker-build
docker-build: ## build the docker image
	docker build -t $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest .

.PHONY: docker-tag
docker-tag: ## tag the :latest docker image with the current version
	docker image tag $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):$(CURRENT_VERSION)

.PHONY: docker-push
docker-push: select-kube-context ## push the current image tag to docker repo
	docker push $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):$(CURRENT_VERSION)

.PHONY: docker-start
docker-start: ## start the docker container
	if docker ps -a | grep $(SERVERREGEX) >/dev/null 2>&1; then        \
		docker start $(DOCKERNAME);                              \
	else                                                             \
		docker run --name $(DOCKERNAME) $(DOCKERPORTS)           \
			-t $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest & \
	fi

.PHONY: docker-build-start
docker-build-start: docker-build docker-start ## build the docker image and start a container

.PHONY: docker-stop
docker-stop: ## stop the docker container
	-docker stop $(DOCKERNAME)

.PHONY: docker-destroy
docker-destroy: docker-stop ## destroy the docker image and container
	-docker rm -f $(DOCKERNAME)
	-docker rmi $(GOOGLE_CLOUD_PREFIX)/$(DOCKERNAME):latest

.PHONY: docker-shell
docker-shell: ## shell into the running docker container
	docker exec -it $(DOCKERNAME) /bin/bash

# vim: set list ts=8 sw=8 noet:
