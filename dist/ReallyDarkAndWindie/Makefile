THUMBSDIR = thumbs
FULLSIZE := $(wildcard *.png)
#THUMBNAILS := $(shell for i in $(FULLSIZE); do echo thumbs/$$i; done)
THUMBNAILS := $(addprefix $(THUMBSDIR)/,$(FULLSIZE))

.PHONY: help # See https://tinyurl.com/makefile-autohelp
help: ## display this help
	@awk -v tab=14 'BEGIN { FS = ":.*## "; buffer = ""; color = "\033[36m"; nocolor = "\033[0m"; indent = "  "; usage(); } function trim(str) { gsub(/[ \t]+$$/, "", str); gsub(/^[ \t]+/, "", str); return str; } function spout(target, desc) { split(trim(target), fields, " "); for (i in fields) printf "%s%s%-" tab "s%s%s\n", indent, color, trim(fields[i]), nocolor, desc; } function usage() { printf "\nUsage:\n%smake %s<target>%s\n\nRecognized targets:\n", indent, color, nocolor; } /\\$$/ { gsub(/\\$$/, ""); buffer = buffer $$0; next; } buffer { $$0 = buffer $$0; buffer = ""; } /^[-a-zA-Z0-9*/%_. ]+:.*## / { pad = sprintf("\n%" tab "s" indent, ""); gsub(/\\n/, pad); spout($$1, $$2); } /^##@ / { gsub(/\\n/, "\n"); printf "\n%s\n", substr($$0, 5) } END { print "" }' $(MAKEFILE_LIST) # v1.54

all: thumbnails ## create all thumbnails

.PHONY: thumbnails
thumbnails: $(THUMBSDIR) $(THUMBNAILS) ## create all thumbnails

$(THUMBSDIR):
	mkdir $(THUMBSDIR)

$(THUMBSDIR)/%.png: %.png
	convert $< -resize 120x120 $@

