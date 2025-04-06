ARG BUILD_FROM=alexjunk/tf_multiarch:ubuntu22.04_numpy1.26.4_tflite2.13.0_paho2.1.0_pymodbus3.6.8

FROM $BUILD_FROM

ARG \
	TARGETPLATFORM \
	VERSION=4.98.2 \
	CODE_SRC=https://github.com/coder/code-server/releases/download \
	TMP=/tmp \
	USER_CODE=/user_code \
	BIOS_LIB=/bios \
	CODE_SERVER_CONF=/vscode \
	EXTENSIONS_DIR=/vscode/extensions \
	PORT=8080

RUN set -x;\
	apt-get update;\
	apt-get install -y --no-install-recommends git iputils-ping net-tools;\
	apt-get install -y --no-install-recommends ca-certificates;\
	#apt-get install -y --no-install-recommends curl;\
	#apt-get install -y --no-install-recommends python3 python3-pip;\
	mkdir $BIOS_DIR;\
	case $TARGETPLATFORM in \
	"linux/amd64")  ARCH="amd64"  ;; \
	"linux/arm/v7") ARCH="armhf"  ;; \
	"linux/arm64") ARCH="arm64"  ;; \
	esac;\
	curl -J -L -o $TMP/code.deb $CODE_SRC/v$VERSION/code-server_${VERSION}_$ARCH.deb;\
	dpkg -i $TMP/code.deb;\
	rm $TMP/code.deb;\
	mkdir $USER_CODE;\
	mkdir $BIOS_LIB;\
 	mkdir -p $EXTENSIONS_DIR;\
	code-server --extensions-dir $EXTENSIONS_DIR --install-extension charliermarsh.ruff;\
	code-server --extensions-dir $EXTENSIONS_DIR --install-extension esbenp.prettier-vscode;\
	code-server --extensions-dir $EXTENSIONS_DIR --install-extension ms-python.python

RUN set -x;\
	echo "port: $PORT" > /config.yaml;\
	echo "user-data-dir: $CODE_SERVER_CONF" >> /config.yaml;\
	echo "extensions-dir: $EXTENSIONS_DIR" >> /config.yaml;\
	echo "host: 0.0.0.0" >> /config.yaml;\
	echo "disable-telemetry: true" >> /config.yaml;\
	echo "disable-update-check: true" >> /config.yaml;\
	echo "auth: none" >> /config.yaml
 
ENV \
	PYTHONPATH=$BIOS_LIB
 
SHELL ["/bin/bash", "-c"]
CMD ["code-server", "/user_code", "--config", "/config.yaml"]
 
