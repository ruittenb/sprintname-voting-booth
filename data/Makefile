COMBINED=total.json
POKEDEX=pokedex.json
USERS=users.json

# automatic self-documentation
.DEFAULT_GOAL:=help

help: ## display this help
	@awk 'BEGIN { FS = ":.*## "; tab = 19; color = "\033[36m"; indent = "  "; printf "\nUsage:\n  make " color "<target>\033[0m\n\nRecognized targets:\n" } /^[a-zA-Z0-9_-]+:.*?## / { pad = sprintf("\n%" tab "s" indent, "", $$2); gsub(/\\n/, pad); printf indent color "%-" tab "s\033[0m%s\n", $$1, $$2 } /^##@ / { gsub(/\\n/, "\n"); printf "\n%s\n", substr($$0, 5) } END { print "" }' $(MAKEFILE_LIST) # v1.42

cleanup: ## cleanup the formatting of 'total'
	jq . < $(COMBINED) > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

combine: ## combine 'pokedex' and 'users' to 'total'
	{                        \
		printf "{\n"       ; \
		printf '"pokedex":'; \
		cat $(POKEDEX)     ; \
		printf ",\n"       ; \
		printf '"users":'  ; \
		cat $(USERS)       ; \
		printf "}\n"       ; \
	} | jq . > $(COMBINED)

split: ## split 'total' into 'pokedex' and 'users'
	jq '.pokedex' $(COMBINED) > $(POKEDEX)
	jq '.users'   $(COMBINED) > $(USERS)

replace-pokedex: ## update 'total' with the data from 'pokedex'
	{                              \
		printf "{\n"             ; \
		printf '"pokedex":'      ; \
		cat $(POKEDEX)           ; \
		printf ",\n"             ; \
		printf '"users":'        ; \
		jq '.users' $(COMBINED)  ; \
		printf "}\n"             ; \
	} | jq . > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

replace-users: ## update 'total' with the data from 'users'
	{                              \
		printf "{\n"             ; \
		printf '"pokedex":'      ; \
		jq '.pokedex' $(COMBINED); \
		printf ",\n"             ; \
		printf '"users":'        ; \
		cat $(USERS)             ; \
		printf "}\n"             ; \
	} | jq . > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

##@ Note: the above commands require the jq(1) command

.PHONY: help cleanup combine split replace-pokedex replace-users

