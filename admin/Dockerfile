ARG BUILD_FROM=alpine:3.16

FROM $BUILD_FROM

ARG \
	PYFINA_VERSION=0.0.6 \
	ENV_DIR=/ve

RUN apk update && apk upgrade;\
	apk add --no-cache tzdata python3 git py3-pip py3-virtualenv py3-numpy;\
	python3 -m venv --system-site-packages $ENV_DIR;\
	$ENV_DIR/bin/pip install --no-cache-dir flask docker;\
	$ENV_DIR/bin/pip install --no-cache-dir PyFina==$PYFINA_VERSION;\
	$ENV_DIR/bin/pip install --no-cache-dir mysql-connector-python redis;\
	$ENV_DIR/bin/pip install --no-cache-dir pyyaml

ENV \
	PATH="${ENV_DIR}/bin:$PATH" \
	TZ="Europe/Paris"
