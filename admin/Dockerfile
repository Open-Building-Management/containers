FROM alpine:3.16

ENV TZ="Europe/Paris"

ARG \
	GITHUB_REPO=https://github.com/numpy/numpy/releases/download \
	NP_OLD_VERSION=1.24.0 \
	NP_VERSION=1.26.2

RUN set -x;\
	apk update && apk upgrade;\
	apk add --no-cache tzdata python3 python3-dev py3-pip;\
	apk add --no-cache build-base;\
	tar --version;\
	python3 --version;\
	python3 -m pip install cython==0.29.32;\
	python3 -m pip install --no-cache-dir flask docker;\
	python3 -m pip install --no-cache-dir mysql-connector-python redis;\
	# the following is not working as there is no wheel on pypi for arm/v7
 	#python3 -m pip3 install --no-cache-dir numpy;\
	wget $GITHUB_REPO/v$NP_VERSION/numpy-$NP_VERSION.tar.gz;\
	tar -xvf *.tar.gz;\
	#cd numpy-$NP_VERSION && touch `find . -type f` && python3 setup.py install;\
	cd numpy-$NP_VERSION && python3 -m pip install .;\
	rm -Rf /numpy-$NP_VERSION;\
	apk del --no-cache build-base python3-dev
	#apk del --no-cache py3-pip
