_RECURSE=0
VERSION?=#
CTANTAG?=git tag  -m "Livraison au CTAN $(DATE)" "ctan$(VERSION)"
TEXMF_INSTALL_DIR?=$(HOME)/texmf
PACKAGE_NAME:=glossaries-french
SRC:=$(addprefix $(PACKAGE_NAME).,dtx ins)
DOC:=$(PACKAGE_NAME).pdf README README.md
DISTTYPE?=dtx

dtxPATH:= dist_forge/dtx
dtxPKG := $(dtxPATH)/$(PACKAGE_NAME)
dtxTDS := $(dtxPATH)/tds
dtxTDsTeX := $(dtxTDS)/tex/latex/$(PACKAGE_NAME)
dtxTDsDoc := $(dtxTDS)/doc/latex/$(PACKAGE_NAME)
dtxTDsSrc := $(dtxTDS)/source/latex/$(PACKAGE_NAME)
dtxDIR := $(dtxPATH) $(dtxPKG) $(dtxTDsDoc) $(dtxTDsTeX) $(dtxTDS)

$(foreach expr,$(join $(addsuffix :=,dtxRevTDsTeX dtxRevTDsDoc dtxRevTDsSrc),\
	$(shell printf "%s\n%s\n%s\n" $(dtxTDsTeX) $(dtxTDsDoc) $(dtxTDsSrc) | sed 's![^/]\+!..!g')), \
   $(eval $(expr)))

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

define GET_VERSION_AWK
BEGIN { FS="[][ \t]+v?" ; found = 0 };
/\\ProvidesGlossariesLang\{[a-z]+\}\[[0-9]+\/[0-9]+\/[0-9]+ v[0-9]+\.[0-9]+\]/ { \
	if ($$1 == "") 	print $$4; else print $$3; \
	found = 1; \
	exit(0) }; \
END { if (found == 0) {print "Version non trouvée" >"/dev/stderr" ; exit(-1) } }
endef

.PHONY: ctantag
ctantag: $(VERSION_M4)
ifeq (0,$(_RECURSE))
	$(MAKE) $@ \
		VERSION=$(shell cat $(PACKAGE_NAME).dtx | awk '$(GET_VERSION_AWK)') \
		DATE=$(shell date '+%Y-%m-%d') _RECURSE=1
else
	@echo 'Effectuer la commande suivante:'
	@echo '$(CTANTAG)'
	@select w in oui non; \
	do \
		case $$w in \
			oui) \
				$(CTANTAG); \
				break;; \
			non) \
				echo 'abandon'; \
				break;; \
		esac; \
	done
endif

.PHONY: ctan
ctan: dist_forge/$(DISTTYPE)/$(PACKAGE_NAME).zip
	@echo ""
	@echo "================================================================================="
	@echo "Livrable : $(abspath dist_forge/$(DISTTYPE)/$(PACKAGE_NAME).zip)"
	@echo "================================================================================="

$(dtxPATH)/$(PACKAGE_NAME).zip: $(DOC) $(SRC) \
	$(dtxPATH)/$(PACKAGE_NAME).tds.zip
	mkdir -p $(dtxPKG)
	for w in $(DOC) $(SRC); do ln -s $$w $(dtxPKG)/$$w; done
	cd $(dtxPATH); zip -r $(PACKAGE_NAME).zip $(PACKAGE_NAME) $(PACKAGE_NAME).tds.zip

$(dtxPATH)/$(PACKAGE_NAME).tds.zip: $(STYFILES) $(DOC) $(SRC)
	mkdir -p $(dtxTDsTeX)
	mkdir -p $(dtxTDsDoc)
	mkdir -p $(dtxTDsSrc)
	cd $(dtxTDsDoc); for w in $(DOC); do ln -s $(dtxRevTDsDoc)/$$w $$w; done
	cd $(dtxTDsTeX); for w in $(STYFILES); do ln -s $(dtxRevTDsTeX)/$$w $$w; done
	cd $(dtxTDsSrc); for w in $(SRC); do ln -s $(dtxRevTDsSrc)/$$w $$w; done
	cd $(dtxTDS); zip -r $(PACKAGE_NAME).tds.zip doc tex source
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
	rm -fr dist_forge
