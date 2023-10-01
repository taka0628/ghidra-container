NAME := ghidra-container
DOCKER_USER_NAME := $(shell cat Dockerfile | grep "ARG _DOCKER_USER" | cut -d "=" -f 2)
DOCKER_HOME_DIR := /home/${DOCKER_USER_NAME}

SHELL := /bin/bash

run:
	make _preExec -s
	-docker container exec -it ${NAME} bash -c "./ghidraRun && bash"
	make _postExec -s

bash:
	make _preExec -s
	-docker container exec -it ${NAME} bash
	make _postExec -s

root:
	make _preExec -s
	-docker container exec --user root -it ${NAME} bash
	make _postExec -s

# キャッシュ有りでビルド
build:
	docker image build -t ${NAME} .
	make _postBuild -s

# dockerのリソースを開放
clean:
	docker system prune

# キャッシュを使わずにビルド
rebuild:
	docker image build -t ${NAME} \
	--build-arg CACHEBUST=${TS} \
	--pull \
	--no-cache=true .
	make _postBuild -s

# コンテナ実行する際の前処理
# 起動，ファイルのコピーを行う
_preExec:
ifneq ($(shell docker ps -a | grep -c ${NAME}),0)
	docker container kill ${NAME}
endif
	-docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	-e DISPLAY=unix${DISPLAY} \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest
	docker cp ../$$(basename $$(pwd)) ${NAME}:${DOCKER_HOME_DIR}/ghidra/hostDir

# コンテナ終了時の後処理
# コンテナ内のファイルをローカルへコピー，コンテナの削除を行う
_postExec:
	docker container kill ${NAME}

# 不要になったビルドイメージを削除
_postBuild:
	if [[ $$(docker images | grep -c ${NAME}) -ne 0 ]]; then\
		 docker image rm $$(docker images -f 'dangling=true' -q);\
	fi


# デバッグ用
test:
	echo $$(basename $$(pwd))