COMBINED=total.json
SETTINGS=settings.json
POKEDEX=pokedex.json
USERS=users.json
PAGES=pages.json

# automatic self-documentation
.DEFAULT_GOAL:=help

.PHONY: help # See https://gist.github.com/ruittenb/5d2d281237385276f49652b9b9f6d5a1
help: ## display this help
	@awk -v tab=19 'BEGIN { FS = ":.*## "; buffer = ""; color = "\033[36m"; nocolor = "\033[0m"; indent = "  "; usage(); } function trim(str) { gsub(/[ \t]+$$/, "", str); gsub(/^[ \t]+/, "", str); return str; } function spout(target, desc) { split(trim(target), fields, " "); for (i in fields) printf "%s%s%-" tab "s%s%s\n", indent, color, trim(fields[i]), nocolor, desc; } function usage() { printf "\nUsage:\n%smake %s<target>%s\n\nRecognized targets:\n", indent, color, nocolor; } /\\$$/ { gsub(/\\$$/, ""); buffer = buffer $$0; next; } buffer { $$0 = buffer $$0; buffer = ""; } /^[-a-zA-Z0-9*/%_. ]+:.*## / { pad = sprintf("\n%" tab "s" indent, ""); gsub(/\\n/, pad); spout($$1, $$2); } /^##@ / { gsub(/\\n/, "\n"); printf "\n%s\n", substr($$0, 5) } END { print "" }' $(MAKEFILE_LIST) # v1.54

.PHONY: cleanup
cleanup: ## cleanup the formatting of 'total'
	jq . < $(COMBINED) > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

.PHONY: combine
combine: ## combine 'settings', 'pages', 'pokedex' and 'users' to 'total'
	{                              \
		printf "{\n"         ; \
		printf '"settings":' ; \
		cat $(SETTINGS)      ; \
		printf ",\n"         ; \
		printf '"pages":'    ; \
		cat $(PAGES)         ; \
		printf ",\n"         ; \
		printf '"pokedex":'  ; \
		cat $(POKEDEX)       ; \
		printf ",\n"         ; \
		printf '"users":'    ; \
		cat $(USERS)         ; \
		printf "}\n"         ; \
	} | jq . > $(COMBINED)

.PHONY: split
split: ## split 'total' into 'settings', 'pages', 'pokedex' and 'users'
	jq '.settings' $(COMBINED) > $(SETTINGS)
	jq '.pages'    $(COMBINED) > $(PAGES)
	jq '.pokedex'  $(COMBINED) > $(POKEDEX)
	jq '.users'    $(COMBINED) > $(USERS)

.PHONY: replace-pokedex
replace-pokedex: ## update 'total' with the data from 'pokedex'
	{                                    \
		printf "{\n"               ; \
		printf '"pages":'          ; \
		jq '.pages' $(COMBINED)    ; \
		printf ",\n"               ; \
		printf '"pokedex":'        ; \
		cat $(POKEDEX)             ; \
		printf ",\n"               ; \
		printf '"settings":'       ; \
		jq '.settings' $(COMBINED) ; \
		printf ",\n"               ; \
		printf '"users":'          ; \
		jq '.users' $(COMBINED)    ; \
		printf "}\n"               ; \
	} | jq . > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

.PHONY: replace-settings
replace-settings: ## update 'total' with the data from 'settings'
	{                                    \
		printf "{\n"               ; \
		printf '"pages":'          ; \
		jq '.pages' $(COMBINED)    ; \
		printf ",\n"               ; \
		printf '"pokedex":'        ; \
		jq '.pokedex' $(COMBINED)  ; \
		printf ",\n"               ; \
		printf '"settings":'       ; \
		cat $(SETTINGS)            ; \
		printf ",\n"               ; \
		printf '"users":'          ; \
		jq '.users' $(COMBINED)    ; \
		printf "}\n"               ; \
	} | jq . > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

.PHONY: replace-users
replace-users: ## update 'total' with the data from 'users'
	{                                    \
		printf "{\n"               ; \
		printf '"pages":'          ; \
		jq '.pages' $(COMBINED)    ; \
		printf ",\n"               ; \
		printf '"pokedex":'        ; \
		jq '.pokedex' $(COMBINED)  ; \
		printf ",\n"               ; \
		printf '"settings":'       ; \
		jq '.settings' $(COMBINED) ; \
		printf ",\n"               ; \
		printf '"users":'          ; \
		cat $(USERS)               ; \
		printf "}\n"               ; \
	} | jq . > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

##@ Note: the above commands require the jq(1) command

mkwinners:
	awk '{ \
		print "    \"winnerNum\": " $$3 ","; \
		print "    \"winnerName\": \"" $$2 "\","; \
		print "    \"startDateString\": \"" $$1 "\","; \
	}' winners.txt > winners.json
