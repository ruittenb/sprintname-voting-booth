all: db.json

db.json:
	{                            \
		printf "{\n";        \
		printf '"pokedex":'; \
		cat pokedex.json;    \
		printf ",\n";        \
		printf '"users":';   \
		cat users.json;      \
		printf "}\n";        \
	} > $@
