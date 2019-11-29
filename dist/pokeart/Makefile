THUMBSDIR = thumbs
FULLSIZE := $(wildcard *.png)
#THUMBNAILS := $(shell for i in $(FULLSIZE); do echo thumbs/$$i; done)
THUMBNAILS := $(addprefix $(THUMBSDIR)/,$(FULLSIZE))

all: thumbnails

.PHONY: thumbnails
thumbnails: $(THUMBSDIR) $(THUMBNAILS)

$(THUMBSDIR):
	mkdir $(THUMBSDIR)

$(THUMBSDIR)/%.png: %.png
	convert $< -resize 120x120 $@

