FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG \
    EP_VERSION=25.2.0 \
    EP_INSTALLER=EnergyPlus-25.2.0-cf7368216c-Linux-Ubuntu22.04-x86_64.sh \
    PYTHON_V=3.12 \
    ENV_DIR=/ve

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    libpython${PYTHON_V} \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN wget https://github.com/NREL/EnergyPlus/releases/download/v${EP_VERSION}/${EP_INSTALLER} -O ep.sh && \
    chmod +x ep.sh && \
    yes | ./ep.sh && \
    rm ep.sh

ENV PATH="/usr/local/EnergyPlus-${EP_VERSION//./-}:${PATH}"

RUN python3 -m venv ${ENV_DIR}
ENV PATH="${ENV_DIR}/bin:${PATH}"

RUN ${ENV_DIR}/bin/pip install --no-cache-dir --upgrade pip;\
    ${ENV_DIR}/bin/pip install --no-cache-dir pyenergyplus-lbnl numpy pandas matplotlib;\
    ${ENV_DIR}/bin/pip install --no-cache-dir honeybee honeybee-energy;\
    ${ENV_DIR}/bin/pip install --no-cache-dir jupyterlab ipympl

# Working dir
WORKDIR /workspace
