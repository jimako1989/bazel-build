FROM ubuntu:16.04
FROM python:latest
# Bazel uses jdk8. Importing jdk8 image in advance, docker runs faster.
# but there are some problem between openjdk8 and Bazel 0.5.3.
FROM openjdk:8

MAINTAINER Tadashi KOJIMA <nsplat@gmail.com>

# To install Bazel, see https://docs.bazel.build/versions/master/install-ubuntu.html#install-with-installer-ubuntu
RUN apt-get update \
  && apt-get install -y pkg-config zip g++ zlib1g-dev unzip \
  && wget https://github.com/bazelbuild/bazel/releases/download/0.5.2/bazel-0.5.2-installer-linux-x86_64.sh \
  && chmod +x ./bazel-0.5.2-installer-linux-x86_64.sh \
  && ./bazel-0.5.2-installer-linux-x86_64.sh \

# run bazel test
  && ls -l bin/ \
  && export PATH="$PATH:/root/bin" \
  && echo $PATH \
  && which bazel \
  && bazel \
  && echo "export PATH=\$PATH:/root/bin" >> /root/.bash_profile \
  && echo "alias python='/usr/bin/python3'" >> /root/.bash_profile \
  && echo "exec /bin/bash" >> /root/.bash_profile \
  && . /root/.bash_profile

# Install basic commands
RUN apt-get install -y make vim less

# Install python modules
RUN apt-get install -y python3-pip python3-dev\
  && pip3 install --upgrade pip numpy setuptools

# TA-Lib
RUN wget https://pypi.python.org/packages/0a/7d/a5f64eadbac6cf7ee41f9ae88fcfee1ff0824ffea529efe1e5cb2dd7e60b/TA-Lib-0.4.16.tar.gz \
  && tar -xvzf TA-Lib-0.4.16.tar.gz\
  && cd TA-Lib-0.4.16/ta-lib/\
  && ./configure --prefix=/usr\
  && make\
  && make install
RUN git clone https://github.com/mrjbq7/ta-lib.git /ta-lib-py\
  && cd ta-lib-py\
  && python3 setup.py install

# Install other modules
RUN apt-get install -y pandoc sqlite3

# Set up workspace
ENV LOCAL_DIST_DIR /home/workspace
WORKDIR /home
