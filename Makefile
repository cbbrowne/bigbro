# $Header: /net/yquem/devel/caml/repository/bigbro/Makefile,v 1.16 2005/01/16 13:19:05 fpottier Exp $
# This Makefile requires GNU make.
# ---------------------------------------------------------------------------------------------------------------------
# If you wish to compile and install Big Brother, do:
#   make
#   make install

all: bigbro

# ---------------------------------------------------------------------------------------------------------------------
# System configuration.

PACKAGE=bigbro-2.0.4-rev3
SOURCE=$(PACKAGE)# The source distribution name.
WINPACK=bb204#

# ---------------------------------------------------------------------------------------------------------------------
# Determining the architecture (to be used in naming the RPM package).

ARCH:=$(shell arch)
ARCH:=$(subst i486,i386,$(ARCH))
ARCH:=$(subst i586,i386,$(ARCH))
ARCH:=$(subst i686,i386,$(ARCH))

# ---------------------------------------------------------------------------------------------------------------------
# More configuration.

CAMLC=ocamlfind ocamlc
CAMLDEP=ocamldep
CAMLMKTOP=ocamlfind ocamlmktop
CAMLP4=camlp4o
P4INCLUDE:=-I $(shell $(CAMLP4) -where)
INCLUDE=-package "unix threads pcre"
COMPFLAGS=-thread -g -pp $(CAMLP4) $(INCLUDE)

# ---------------------------------------------------------------------------------------------------------------------
# The list of bytecode files to be linked.

GRAMMAR=pcreg

OBJS=thread_utils.cmo misc.cmo settings.cmo string_utils.cmo io_utils.cmo sysmagic.cmo base64.cmo url_syntax.cmo url.cmo media_type.cmo timer.cmo agency.cmo linear_connection.cmo http_connection.cmo stats.cmo link_info.cmo stripper.cmo skimmer.cmo fragment_skimmer.cmo link_skimmer.cmo cache.cmo check_file.cmo check_master.cmo check_http.cmo main.cmo

# ---------------------------------------------------------------------------------------------------------------------
# How to build the main executable.

bigbro: $(OBJS)
	$(CAMLC) -o bigbro -thread -custom -linkpkg $(INCLUDE) $(OBJS)

# ---------------------------------------------------------------------------------------------------------------------
# How to build a custom toplevel. Used for debugging only.

mytop: $(OBJS)
	$(CAMLMKTOP) -o mytop -thread -custom -linkpkg $(INCLUDE) $(OBJS)

# ---------------------------------------------------------------------------------------------------------------------
# Cleaning up.
# We remove:
#   The package directory and the RPM/zip packages.
#   The renamed copy of the system dependent module.
#   The executables.
#   Any generated binary or editor file.
#   The generated dependency file.

clean::
	rm -rf $(PACKAGE) $(PACKAGE).tar.gz $(SOURCE) $(SOURCE).tar.gz *.rpm *.zip
	rm -f sysmagic.ml sysmagic.mli
	rm -f bigbro mytop
	rm -f *.cmi *.cmx *.cmo *.ppo *.o *.obj *~ #*#
	rm -f .generated-dependencies

# ---------------------------------------------------------------------------------------------------------------------
# Installing. (Useful for those who don't use the rpm package.)
# Requires $(PREFIX) to be set.

BINDIR=$(PREFIX)/bin
MANDIR=$(PREFIX)/man/man1
DOCDIR=$(PREFIX)/doc
DOCSUBDIR=apps-bigbro#  for GODI.
# DOCSUBDIR=$(PACKAGE)# for RedHat RPM. TEMPORARY
DOCFILES=doc/README doc/doc.ps doc/doc.pdf doc/html

# TEMPORARY pour construire le RPM, ajouter -o 0 -g 0 aux deux premiers install
# et chown -R root.root $(DOCDIR)/$(PACKAGE) avant le dernier chmod ?

install: bigbro
	install -d $(BINDIR)
	install -m 755 bigbro $(BINDIR)/bigbro
	install -d $(MANDIR)
	install -m 644 doc/bigbro.1 $(MANDIR)/bigbro.1
	install -d $(DOCDIR)/$(DOCSUBDIR)
	cp -r $(DOCFILES) $(DOCDIR)/$(DOCSUBDIR)
	chmod -R a=rX,u+w $(DOCDIR)/$(DOCSUBDIR)

deinstall:
	rm -rf $(BINDIR)/bigbro $(MANDIR)/bigbro.1 $(DOCDIR)/$(DOCSUBDIR)

# ---------------------------------------------------------------------------------------------------------------------
# The usual way to compile O'Caml programs.

.generated-dependencies: *.ml *.mli
	$(CAMLC) -pp $(CAMLP4) $(P4INCLUDE) -c $(GRAMMAR).ml
	rm -rf .generated-dependencies
	for i in *.mli *.ml ; do \
		$(CAMLP4) pr_depend.cmo $$i >> .generated-dependencies; \
	done

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),source)
-include .generated-dependencies
endif
endif

.SUFFIXES: .mli .cmi .ml .cmo

.mli.cmi:
	$(CAMLC) $(COMPFLAGS) -c $<

.ml.cmo: $(GRAMMAR).cmo
	$(CAMLC) $(COMPFLAGS) -c $<

# ---------------------------------------------------------------------------------------------------------------------
# A bit of magic.
# The Sysmagic module should be a renamed copy of Sysunix.
# We make it write-protected to remind the programmer that it shouldn't be edited.

sysmagic.ml: sysunix.ml
	rm -f sysmagic.ml
	cp sysunix.ml sysmagic.ml
	chmod a-w sysmagic.ml

sysmagic.mli: sysunix.mli
	rm -f sysmagic.mli
	cp sysunix.mli sysmagic.mli
	chmod a-w sysmagic.mli

# ---------------------------------------------------------------------------------------------------------------------
# Building a RPM package under RedHat Linux.
#   'make package' prepares the package directory and must be run as user.
#   'make rpm' compiles the package into an RPM file and must be run as root.
#   'make rpmi' and 'make rpme' are simple shortcuts to install/remove the RPM package and must be run as root.

package:
	make clean
	make
	(cd doc; make all)
	mkdir $(PACKAGE)
	cp -r bigbro doc/README doc/bigbro.1 doc/doc.ps doc/doc.pdf doc/html $(PACKAGE)
	tar cvfz $(PACKAGE).tar.gz $(PACKAGE)

rpm:
	cp $(PACKAGE).tar.gz /usr/src/redhat/SOURCES
	export PREFIX="/usr"; rpmbuild -bb --clean spec
	rm -rf /usr/src/redhat/SOURCES/$(PACKAGE).tar.gz
	rm -rf /usr/bin/bigbro /usr/man/man1/bigbro.1 /usr/doc/$(PACKAGE)-1
	mv /usr/src/redhat/RPMS/$(ARCH)/$(PACKAGE)-1.$(ARCH).rpm .
	chown root:root $(PACKAGE)-1.$(ARCH).rpm

rpmi:
	rpm -i $(PACKAGE)-1.$(ARCH).rpm

rpme:
	rpm -e $(PACKAGE)

# ---------------------------------------------------------------------------------------------------------------------
# Creating a source distribution.

source:
	make clean
	(cd doc; make all)
	mkdir $(SOURCE)
	-cp * $(SOURCE)
	mkdir $(SOURCE)/doc
	cp -r doc/README doc/bigbro.1 doc/doc.ps doc/doc.pdf doc/html $(SOURCE)/doc
	tar cvfz $(SOURCE).tar.gz $(SOURCE)

# For myself.
#	scp $(SOURCE).tar.gz yquem.inria.fr:public_html/bigbro/
#	godiva -refetch -localbase $GODI_HOME spec.godiva

htdoc:
	(cd doc; make html)

# ---------------------------------------------------------------------------------------------------------------------
# Zipping a package built under Windows.
# I don't have a command-line version of pkzip under Windows, so I zip the file under Linux afterwards.

winzip:
	(cd /mnt/winnt/bigbrother; zip -9 -r - ./$(WINPACK)) > $(WINPACK).zip

