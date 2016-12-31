MAJOR    ?= 0
MINOR    ?= 0
SUB      ?= 1
PATCH    ?= 1
MD5SUM    = md5sum
SEDI      = sed -i

ifeq ($(shell uname), Darwin)
        MD5SUM = md5 -r
        SEDI   = sed -i ""
endif

all: manifest
	make setup
	make test

versions:
	find lib t -type f -exec perl -i -pe 's/VERSION\s+=\s+q[[\d.]+]/VERSION = q[$(MAJOR).$(MINOR).$(SUB)]/g' {} \;

setup:
	perl Build.PL
	./Build

test: setup
	./Build test

cover: manifest setup
	[ ! -d cover_db ] || rm -rf cover_db
	./Build testcover

manifest: clean
	touch MANIFEST
	rm MANIFEST
	make setup
	./Build manifest

clean: setup
	./Build clean

dist: all
	./Build dist

deb:	manifest
	make test
	touch tmp
	rm -rf tmp
	mkdir -p tmp/usr/share/perl5
	cp -pR deb-src/* tmp/
	cp tmp/DEBIAN/control.tmpl tmp/DEBIAN/control
	$(SEDI) "s/MAJOR/$(MAJOR)/g" tmp/DEBIAN/control
	$(SEDI) "s/MINOR/$(MINOR)/g" tmp/DEBIAN/control
	$(SEDI) "s/SUB/$(SUB)/g"     tmp/DEBIAN/control
	$(SEDI) "s/PATCH/$(PATCH)/g" tmp/DEBIAN/control
	$(SEDI) "s/RELEASE/$(RELEASE)/g" tmp/DEBIAN/control
	rsync --exclude .svn --exclude .git -va lib/* tmp/usr/share/perl5/
	rsync --exclude .svn --exclude .git -va bin/* tmp/usr/bin/
	find tmp -type f ! -regex '.*\(\bDEBIAN\b\|\.\bsvn\b\|\bdeb-src\b\|\.\bgit\b\|\.\bsass-cache\b\|\.\bnetbeans\b\).*'  -exec $(MD5SUM) {} \; | sed 's/tmp\///' > tmp/DEBIAN/md5sums
	(cd tmp; fakeroot dpkg -b . ../libham-noaa-sunspot-perl-$(MAJOR).$(MINOR).$(SUB)-$(PATCH).deb)

cpan:	clean
	make dist
	cpan-upload Ham-NOAA-Sunspot-v$(MAJOR).$(MINOR).$(SUB)-$(PATCH).tar.gz

debdeps:
	grep Depends deb-src/DEBIAN/control.tt2  | cut -d : -f 2 | sed 's/,/ /g' | xargs sudo apt-get install
	grep Recommends deb-src/DEBIAN/control.tt2  | cut -d : -f 2 | sed 's/,/ /g' | xargs sudo apt-get install
