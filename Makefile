SHOWS = $(shell cat shows | cut -f 1)
SCRIPTS = PKGBUILD scroll


.PHONY: all
all:
	mkdir -p quotes
	for show in $(SHOWS); do \
	    realshow="$$(cat shows | grep "^$${show}	" | cut -f 2)" && \
	    real_show="$$(echo "$${realshow}" | sed -e 's: :_:g')" && \
	    mkdir -p quotes/$${show} && \
	    cd quotes/$${show} && \
	    wikiquote-fortune "$${realshow}" && \
	    strfile quotes && \
	    mv quotes.dat $${show}.dat && \
	    mv quotes $${show} && \
	    realshow="$$(echo "$${realshow}" | sed -e 's:\&:\\\&:g')" && \
	    real_show="$$(echo "$${real_show}" | sed -e 's:\&:\\\&:g')" && \
	    for script in $(SCRIPTS); do \
	        cp ../../$${script}.template $${script} && \
	        sed -i "s/%UNIXSHOW%/$${show}/g" $${script} && \
	        sed -i "s/%REALSHOW%/$${realshow}/g" $${script} && \
	        sed -i "s/%REAL_SHOW%/$${real_show}/g" $${script} && \
	        sed -i "s/%VERSION%/$$(cat version)/g" $${script} || exit 1; \
	        if [ $${script} = scroll ]; then \
	            mv $${script} fortune-mod-$${show}.scroll || exit 1; \
	        fi; \
	    done && \
	    cd ../.. || exit 1; \
	done


.PHONY: archive
archive:
	for show in $(SHOWS); do \
	    git rm archive/$${show}.* && \
	    cp quotes/$${show}/$${show} archive/$${show}.$$(cat quotes/$${show}/version) && \
	    git add archive/$${show}.$$(cat quotes/$${show}/version) || exit 1; \
	done


.PHONY: makepkg-install
makepkg-install:
	for show in $(SHOWS); do \
	    cd quotes/$${show} && \
	    makepkg --install && \
	    cd ../.. || exit 1; \
	done


.PHONY: aur-upload
aur-upload:
	for show in $(SHOWS); do \
	    cd quotes/$${show} && \
	    ../../aur-upload && \
	    cd ../.. || exit 1; \
	done


.PHONY: clean
clean:
	-rm -r -- $(foreach S, $(SHOWS), quotes/$(S))
	-rmdir quotes

