FROM alpine:3.16

ENV TZ="Europe/Paris"

RUN apk update && apk upgrade;\
	apk add --no-cache python3;\
	apk add --no-cache py3-pip;\
	pip3 install --no-cache-dir flask docker;\
	pip3 install --no-cache-dir mysql-connector-python redis
	#apk del --no-cache py3-pip
