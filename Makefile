_RESURSE?=0
TEXMF_INSTALL_DIR?=$(HOME)/texmf
PACKAGE_NAME:=glossaries-french
DISTTYPE?=dtx

dtxPATH:= dist_forge/dtx
dtxPKG := $(dtxPATH)/$(PACKAGE_NAME)
dtxTDS := $(dtxPATH)/tds
dtxTDsTeX := $(dtxTDS)/tex/latex/$(PACKAGE_NAME)
dtxTDsDoc := $(dtxTDS)/doc/latex/$(PACKAGE_NAME)
dtxDIR := $(dtxPATH) $(dtxPKG) $(dtxTDsDoc) $(dtxTDsTeX) $(dtxTDS)


STYFILES:=glossaries-dictionary-French.dict $(PACKAGE_NAME).ldf

define INSTALL
.PHONY: install$(1)
install$(1): $(PACKAGE_NAME).pdf
ifeq ($(strip $(_RESURSE)),0)
	$$(MAKE) _RESURSE=1 "$(2)=$(3)" $$@
else
	$$(call DO_INSTALL,$$($(2)))
endif
endef

define DO_INSTALL
mkdir -p $(1)/tex/latex/$(PACKAGE_NAME)
for w in $(STYFILES); do cp -u $$w $(1)/tex/latex/$(PACKAGE_NAME); done
mkdir -p $(1)/doc/latex/$(PACKAGE_NAME)
cp -u $(PACKAGE_NAME).pdf $(1)/doc/latex/$(PACKAGE_NAME)
endef

.PHONY: install
install: $(PACKAGE_NAME).pdf $(STYFILES)
	$(call DO_INSTALL,$(TEXMF_INSTALL_DIR))

$(eval $(call INSTALL,local,TEXMFLOCAL,$$(shell kpsewhich -var-value=TEXMFLOCAL)))

$(eval $(call INSTALL,home,TEXMFHOME,$$(or $$(shell kpsewhich -var-value=TEXMFHOME),$$(HOME)/texmf)))

.PHONY: ctan
ctan: dist_forge/$(DISTTYPE)/$(PACKAGE_NAME).zip


$(dtxPATH)/$(PACKAGE_NAME).zip: $(addprefix $(PACKAGE_NAME).,ins dtx pdf) README README.md \
	$(dtxPATH)/$(PACKAGE_NAME).tds.zip
	mkdir -p $(dtxPKG)
	for w in $(PACKAGE_NAME).dtx README README.md; do ln -s $$w $(dtxPKG)/$$w; done
	cd $(dtxPATH); zip -r $(PACKAGE_NAME).zip $(PACKAGE_NAME) $(PACKAGE_NAME).tds.zip

$(dtxPATH)/$(PACKAGE_NAME).tds.zip: $(PACKAGE_NAME).pdf $(STYFILES) README README.md
	mkdir -p $(dtxTDsTeX)
	mkdir -p $(dtxTDsDoc)
	for w in $(PACKAGE_NAME).pdf README README.md; do ln -s $$w $(dtxTDsDoc)/$$w; done
	for w in $(STYFILES); do ln -s $$w $(dtxTDsTeX)/$$w; done
	cd $(dtxTDS); zip -r $(PACKAGE_NAME).tds.zip doc tex
	mv $(dtxTDS)/$(PACKAGE_NAME).tds.zip $(dtxPATH)


.PHONY: doc
doc: $(PACKAGE_NAME).pdf

$(PACKAGE_NAME).pdf: $(PACKAGE_NAME).dtx
	pdflatex $<

$(STYFILES):%: $(PACKAGE_NAME).ins $(PACKAGE_NAME).dtx
	latex $<

.PHONY: clean
clean:
	rm -f $(addprefix $(PACKAGE_NAME).,log aux)

# juste un synonyme de realclean
.PHONY: squeaky
squeaky: realclean

.PHONY: realclean
realclean: clean
	rm -f $(STYFILES)
