TEXT_PAGINATION := true
LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif

cde-lists.md: draft-ietf-cbor-cde.xml
	kramdown-rfc-extract-figures-tables -trfc $< >$@.new
	mv $@.new $@

example-tables.md: example-table-input.csv generate-tables.rb
	ruby generate-tables.rb > $@.new
	if cmp $@.new $@; then rm -v $@.new; else mv -v $@.new $@; fi
