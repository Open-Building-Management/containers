FROM alpine:3.16

ENV TZ="Europe/Paris"

RUN apk update && apk upgrade;\
	apk add --no-cache tzdata python3 py3-pip;\
	pip3 install --no-cache-dir flask docker;\
	pip3 install --no-cache-dir mysql-connector-python redis;\
	python3 -m pip install cython;\
 	#pip3 install --no-cache-dir numpy;\
	wget https://files.pythonhosted.org/packages/dd/2b/205ddff2314d4eea852e31d53b8e55eb3f32b292efc3dd86bd827ab9019d/numpy-1.26.2.tar.gz;\
	tar -xvf numpy*;\
	cd numpy-1.26.2;\
	python3 setup.py install
	#apk del --no-cache py3-pip
