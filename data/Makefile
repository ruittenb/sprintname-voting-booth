COMBINED=db.json

usage:
	@echo "Usage:"
	@echo "  make usage    : print this usage text"
	@echo "  make compose  : create $(COMBINED) from {pokedex,users}.json"
	@echo "  make decompose: split  $(COMBINED) into {pokedex,users}.json"
	@echo
	@echo "Note: this needs jq(1)"

compose:
	{                            \
		printf "{\n"       ; \
		printf '"pokedex":'; \
		cat pokedex.json   ; \
		printf ",\n"       ; \
		printf '"users":'  ; \
		cat users.json     ; \
		printf "}\n"       ; \
	} > $(COMBINED)


decompose:
	jq '.pokedex' $(COMBINED) > pokedex.json
	jq '.users'   $(COMBINED) > users.json

.PHONY: usage compose decompose
