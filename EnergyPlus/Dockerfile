FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG \
    EP_VERSION=25.2.0 \
    EP_INSTALLER=https://github.com/NREL/EnergyPlus/releases/download/v25.2.0/EnergyPlus-25.2.0-cf7368216c-Linux-Ubuntu22.04-x86_64.tar.gz \
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

RUN wget $EP_INSTALLER \
    -O /tmp/ep.tar.gz && \
    mkdir -p /opt/energyplus && \
    tar -xzf /tmp/ep.tar.gz -C /opt/energyplus --strip-components=1 && \
    rm /tmp/ep.tar.gz

ENV PATH="/opt/energyplus:${PATH}"

RUN python3 -m venv ${ENV_DIR}
ENV PATH="${ENV_DIR}/bin:${PATH}"

RUN ${ENV_DIR}/bin/pip install --no-cache-dir --upgrade pip;\
    ${ENV_DIR}/bin/pip install --no-cache-dir pyenergyplus-lbnl numpy pandas matplotlib;\
    ${ENV_DIR}/bin/pip install --no-cache-dir honeybee honeybee-energy;\
    ${ENV_DIR}/bin/pip install --no-cache-dir jupyterlab ipympl;\
    ${ENV_DIR}/bin/pip install --no-cache-dir pylint mypy

# Working dir
WORKDIR /workspace
