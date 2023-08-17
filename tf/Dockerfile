FROM ubuntu:latest

RUN apt-get -y update;\
    apt-get -y upgrade;\
    apt-get -y install python3;\
    python3 -m pip install pip --upgrade;\
    python3 -m pip install --no-cache-dir tflite-runtime;\
    echo "import tflite_runtime.interpreter as tflite" >> test.py

CMD ["python3", "test.py"]
