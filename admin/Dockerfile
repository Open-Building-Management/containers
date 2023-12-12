FROM alpine:3.16

ENV TZ="Europe/Paris"

RUN apk update && apk upgrade;\
	apk add --no-cache tzdata python3 py3-pip;\
	pip3 install --no-cache-dir flask docker;\
	pip3 install --no-cache-dir mysql-connector-python redis
 	pip3 install --no-cache-dir numpy
	#apk del --no-cache py3-pip
