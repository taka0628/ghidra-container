FROM ubuntu:22.04

# ユーザー名
ARG _DOCKER_USER=Guest

# 対話モードを拒否
ENV DEBIAN_FRONTEND noninteractive

ARG APT_LINK=http://ftp.riken.jp/Linux/ubuntu/
RUN sed -i "s-$(cat /etc/apt/sources.list | grep -v "#" | cut -d " " -f 2 | grep -v "security" | sed "/^$/d" | sed -n 1p)-${APT_LINK}-g" /etc/apt/sources.list

# ターミナルで日本語の出力を可能にするための設定
RUN apt-get update\
	&& apt-get install -y\
	language-pack-ja\
	bash-completion\
	gnome-terminal\
	fonts-noto-cjk

RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
RUN update-locale LANG=ja_JP.UTF-8

# GUI出力のためのパッケージ
RUN apt-get install -y\
	xterm\
	x11-xserver-utils\
	dbus-x11\
	libcanberra-gtk*

ENV DIRPATH /home/${_DOCKER_USER}
WORKDIR $DIRPATH

# Ghidraに必要なパッケージを取得
RUN apt-get install -y \
	wget\
	unzip\
	openjdk-19-jdk

# ユーザ設定
RUN useradd ${_DOCKER_USER}\
	&& chown -R ${_DOCKER_USER} ${DIRPATH}
USER ${_DOCKER_USER}

# Ghidraをインストール
RUN wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip\
	&& unzip ghidra_10.4_PUBLIC_20230928.zip\
	&& mv ghidra_10.4_PUBLIC ghidra\
	&& rm ghidra_10.4_PUBLIC_20230928.zip


WORKDIR ${DIRPATH}/ghidra