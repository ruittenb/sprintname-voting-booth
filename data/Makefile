COMBINED=total.json
SETTINGS=settings.json
POKEDEX=pokedex.json
USERS=users.json
PAGES=pages.json

.DEFAULT_GOAL:=help

# automatic self-documentation
.PHONY: help # See https://tinyurl.com/makefile-autohelp
help: ## display this help
	@awk -v tab=12 'BEGIN{FS=":.*## ";c="\033[36m";m="\033[0m";y="  ";a=2;h()}function t(s){gsub(/[ \t]+$$/,"",s);gsub(/^[ \t]+/,"",s);return s}function u(g,d){split(t(g),f," ");for(j in f)printf"%s%s%-"tab"s%s%s\n",y,c,t(f[j]),m,d}function h(){printf"\nUsage:\n%smake %s<target>%s\n\nRecognized targets:\n",y,c,m}/\\$$/{gsub(/\\$$/,"");b=b$$0;next}b{$$0=b$$0;b=""}/^[-a-zA-Z0-9*/%_. ]+:.*## /{p=sprintf("\n%"(tab+a)"s"y,"");gsub(/\\n/,p);if($$1~/%/&&$$2~/^%:/){n=split($$2,q,/%:|:% */);for(i=2;i<n;i+=2){g=$$1;sub(/%/,q[i],g);u(g,q[i+1])}}else if($$1~/%/&&$$2~/%:[^%]+:[^%]+:%/){d=$$2;sub(/^.*%:/,"",d);sub(/:%.*/,"",d);n=split(d,q,/:/);for(i=1;i <= n;i++){g=$$1;d=$$2;sub(/%/,q[i],g);sub(/%:[^%]+:%/,q[i],d);u(g,d)}}else u($$1,$$2)}/^##@ /{gsub(/\\n/,"\n");printf"\n%s\n",substr($$0,5)}END{print""}' $(MAKEFILE_LIST) # v1.58


.PHONY: cleanup
cleanup: ## cleanup the formatting of 'total'
	jq . < $(COMBINED) > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

.PHONY: combine
combine: ## combine 'settings', 'pages', 'pokedex' and 'users' to 'total'
	{                              \
		printf "{\n"         ; \
		printf '"pages":'    ; \
		cat $(PAGES)         ; \
		printf ",\n"         ; \
		printf '"pokedex":'  ; \
		cat $(POKEDEX)       ; \
		printf ",\n"         ; \
		printf '"settings":' ; \
		cat $(SETTINGS)      ; \
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

##@ Note: the above commands require the jq(1) command

