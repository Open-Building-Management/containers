FROM alpine:3.16

ENV TZ="Europe/Paris"

RUN apk update && apk upgrade;\
	apk add --no-cache tzdata python3 py3-pip py3-numpy;\
	pip3 install --no-cache-dir flask docker;\
	pip3 install --no-cache-dir mysql-connector-python redis
