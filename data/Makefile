COMBINED=total.json
POKEDEX=pokedex.json
USERS=users.json

usage:
	@echo "Usage:"
	@echo "  make usage   : print this usage text"
	@echo "  make cleanup : beautify $(COMBINED)"
	@echo "  make combine : create $(COMBINED) from $(POKEDEX) and $(USERS)"
	@echo "  make split   : split  $(COMBINED) into $(POKEDEX) and $(USERS)"
	@echo "  make replace-pokedex: replace pokedex in $(COMBINED) with $(POKEDEX)"
	@echo "  make replace-users  : replace users   in $(COMBINED) with $(USERS)"
	@echo
	@echo "Note: this needs jq(1)"

cleanup:
	jq . < $(COMBINED) > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

combine:
	{                            \
		printf "{\n"       ; \
		printf '"pokedex":'; \
		cat $(POKEDEX)     ; \
		printf ",\n"       ; \
		printf '"users":'  ; \
		cat $(USERS)       ; \
		printf "}\n"       ; \
	} | jq . > $(COMBINED)

split:
	jq '.pokedex' $(COMBINED) > $(POKEDEX)
	jq '.users'   $(COMBINED) > $(USERS)

replace-pokedex:
	{                                  \
		printf "{\n"             ; \
		printf '"pokedex":'      ; \
		cat $(POKEDEX)           ; \
		printf ",\n"             ; \
		printf '"users":'        ; \
		jq '.users' $(COMBINED)  ; \
		printf "}\n"             ; \
	} | jq . > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

replace-users:
	{                                  \
		printf "{\n"             ; \
		printf '"pokedex":'      ; \
		jq '.pokedex' $(COMBINED); \
		printf ",\n"             ; \
		printf '"users":'        ; \
		cat $(USERS)             ; \
		printf "}\n"             ; \
	} | jq . > $(COMBINED).new
	mv $(COMBINED).new $(COMBINED)

.PHONY: usage cleanup combine split replace-pokedex replace-users
