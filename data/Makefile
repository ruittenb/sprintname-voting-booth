COMBINED=db.json
POKEDEX=pokedex.json
USERS=users.json

usage:
	@echo "Usage:"
	@echo "  make usage    : print this usage text"
	@echo "  make compose  : create $(COMBINED) from $(POKEDEX) and $(USERS)"
	@echo "  make decompose: split  $(COMBINED) into $(POKEDEX) and $(USERS)"
	@echo
	@echo "Note: this needs jq(1)"

compose:
	{                            \
		printf "{\n"       ; \
		printf '"pokedex":'; \
		cat $(POKEDEX)     ; \
		printf ",\n"       ; \
		printf '"users":'  ; \
		cat $(USERS)       ; \
		printf "}\n"       ; \
	} > $(COMBINED)


decompose:
	jq '.pokedex' $(COMBINED) > $(POKEDEX)
	jq '.users'   $(COMBINED) > $(USERS)

.PHONY: usage compose decompose
