# Copyright (c) 2023 Haofan Zheng
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

############################### Install packages ###############################
RUN apt-get update -y && \
	apt-get install -y \
		apt-utils \
		lsb-release

RUN apt-get update -y && \
	apt-get upgrade -y

RUN apt-get update -y && \
	apt-get install -y \
		nano \
		less \
		unzip \
		net-tools \
		iputils-ping \
		git \
		curl \
		build-essential \
		cmake=3.22.1-1ubuntu1.22.04.2 \
		python3=3.10.6-1~22.04 \
		python3-venv=3.10.6-1~22.04 \
		python3-pip=22.0.2+dfsg-1ubuntu0.4 \
        clang 
        
        
# install ghcup
RUN curl https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > /usr/bin/ghcup 
RUN chmod +x /usr/bin/ghcup 

ARG GHC=8.6.5
ARG CABAL=latest

# install GHC and cabal
RUN ghcup -v install ghc --isolate /usr/local --force ${GHC} 
RUN ghcup -v install cabal --isolate /usr/local/bin --force ${CABAL}


# SSH Server
RUN apt-get update -y && \
	apt-get install -y \
		openssh-server
RUN rm /etc/ssh/ssh_host_*

##########
# SGX Linux SDK
##########

ARG LINUX_SGX_VER=2.23
ARG SGX_SDK_VER=${LINUX_SGX_VER}.100.2

# SGX PSW
RUN curl \
	-o /opt/sgx_debian_local_repo.tgz \
	-fSL https://download.01.org/intel-sgx/sgx-linux/${LINUX_SGX_VER}/distro/ubuntu22.04-server/sgx_debian_local_repo.tgz

RUN tar -xzf /opt/sgx_debian_local_repo.tgz -C /opt
RUN echo 'deb [arch=amd64 trusted=yes] file:/opt/sgx_debian_local_repo/ jammy main' > /etc/apt/sources.list.d/intel-sgx.list
RUN apt-get update -y
RUN apt install -y \
	libsgx-enclave-common \
	libsgx-enclave-common-dbgsym \
	libsgx-urts \
	libsgx-urts-dbgsym \
	libsgx-epid \
	libsgx-uae-service

# AESM Service

# SGX SDK
RUN curl \
	-o /opt/sgx_linux_x64_sdk.bin \
	-fSL https://download.01.org/intel-sgx/sgx-linux/${LINUX_SGX_VER}/distro/ubuntu22.04-server/sgx_linux_x64_sdk_${SGX_SDK_VER}.bin
RUN chmod 755 /opt/sgx_linux_x64_sdk.bin
RUN /opt/sgx_linux_x64_sdk.bin --prefix /opt/intel


RUN cabal update
RUN apt-get install -y libgmp3-dev
RUN git clone https://github.com/martinovjulian/docker-hastee.git
WORKDIR "/docker-hastee"
RUN pip install jinja2
RUN openssl genrsa -out ssl/ca.key 2048
RUN openssl req -x509 -new -nodes -key ssl/ca.key -sha256 -days 1024 -out ssl/ca.crt -config ssl/ca_config.conf
RUN openssl genrsa -out ssl/server.key 2048
RUN openssl req -new -key ssl/server.key -out ssl/server.csr -config ssl/ca_config.conf
RUN openssl x509 -req -days 360 -in ssl/server.csr -CA ssl/ca.crt -CAkey ssl/ca.key -CAcreateserial -out ssl/server.crt
RUN cabal build --project-file=cabal-nosgx.project


# APT clean up
# RUN apt-get autoremove -y
# RUN apt-get clean all
################################################################################

ENV DEBIAN_FRONTEND=

ENV LANG=C.UTF-8

# entrypoint


# ENTRYPOINT [ "/bin/sgx-init", "/bin/bash" ]

ENTRYPOINT [ "/bin/bash" ]
