
PATH+=:../node_modules/.bin/
ELM_MAIN:= ../src/Main.elm
ELM_MISC:= ../src/Msgs.elm ../src/Ports.elm ../src/Routing.elm
ELM_CONSTANTS:= ../src/Constants.elm ../src/Constants/Authentication.elm ../src/Constants/Database.elm
ELM_MODELS:= ../src/Models.elm ../src/Models/Auth.elm ../src/Models/Authentication.elm \
	../src/Models/Database.elm ../src/Models/Pokemon.elm ../src/Models/Ratings.elm ../src/Models/Types.elm
ELM_UPDATE:= ../src/Update.elm ../src/Update/Authentication.elm ../src/Update/Pokemon.elm ../src/Update/Ratings.elm
ELM_VIEW:= ../src/View.elm ../src/View/Application.elm ../src/View/Calculations.elm ../src/View/Pokemon.elm
ELM_COMMANDS:= ../src/Commands.elm ../src/Commands/Authentication.elm ../src/Commands/Database.elm \
	../src/Commands/Pokemon.elm ../src/Commands/Ratings.elm
ELM_HELPERS:= ../src/Helpers.elm ../src/Helpers/Authentication.elm

Elm.js: $(ELM_MAIN) $(ELM_MISC) $(ELM_CONSTANTS) $(ELM_MODELS) $(ELM_UPDATE) $(ELM_VIEW) $(ELM_COMMANDS) $(ELM_HELPERS)
	elm-make $(ELM_MAIN) --output $@

bundle.js: Elm.js app.js
	browserify app.js -o $@
	uglifyjs $@ --compress --mangle --output ../dist/$@

build: bundle.js

.PHONY: build
