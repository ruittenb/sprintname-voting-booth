COMBINED=db.json
POKEDEX=pokedex.json
USERS=users.json

usage:
	@echo "Usage:"
	@echo "  make usage   : print this usage text"
	@echo "  make combine : create $(COMBINED) from $(POKEDEX) and $(USERS)"
	@echo "  make split   : split  $(COMBINED) into $(POKEDEX) and $(USERS)"
	@echo
	@echo "Note: this needs jq(1)"

combine:
	{                            \
		printf "{\n"       ; \
		printf '"pokedex":'; \
		cat $(POKEDEX)     ; \
		printf ",\n"       ; \
		printf '"users":'  ; \
		cat $(USERS)       ; \
		printf "}\n"       ; \
	} > $(COMBINED)


split:
	jq '.pokedex' $(COMBINED) > $(POKEDEX)
	jq '.users'   $(COMBINED) > $(USERS)

.PHONY: usage combine split
