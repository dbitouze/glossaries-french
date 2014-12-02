_RESURSE?=0
TEXMF_INSTALL_DIR?=$(HOME)/texmf
PACKAGE_NAME:=glossaries-french

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
cp -u $(PACKAGE_NAME).ldf $(1)/tex/latex/$(PACKAGE_NAME)
cp -u glossaries-dictionary-French.dict $(1)/tex/latex/$(PACKAGE_NAME)
mkdir -p $(1)/doc/latex/$(PACKAGE_NAME)
cp -u $(PACKAGE_NAME).pdf $(1)/doc/latex/$(PACKAGE_NAME)
endef

.PHONY: install
install: $(PACKAGE_NAME).pdf $(STYFILES)
	$(call DO_INSTALL,$(TEXMF_INSTALL_DIR))

$(eval $(call INSTALL,local,TEXMFLOCAL,$$(shell kpsewhich -var-value=TEXMFLOCAL)))

$(eval $(call INSTALL,home,TEXMFHOME,$$(or $$(shell kpsewhich -var-value=TEXMFHOME),$$(HOME)/texmf)))


$(PACKAGE_NAME).pdf: $(PACKAGE_NAME).dtx
	pdflatex $<

$(STYFILES):%: $(PACKAGE_NAME).ins $(PACKAGE_NAME).dtx
	latex $<

.PHONY: clean
clean:
	rm -f $(addprefix $(PACKAGE_NAME).,log aux)

.PHONY: squeaky
squeaky: clean
	rm -f $(STYFILES)
