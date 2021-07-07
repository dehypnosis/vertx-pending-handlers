#!/usr/bin/env bash

# enter into current module directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# will be run on local or docker container
LOCAL_APP_BIN_PATH="./build/install/t-connection/bin/t-connection"
DOCKER_APP_BIN_PATH="./bin/t-connection"
APP_BIN_PATH=$(test -f "$DOCKER_APP_BIN_PATH" && echo "$DOCKER_APP_BIN_PATH" || echo "$LOCAL_APP_BIN_PATH")

# assure latest build for local run
if [[ "$LOCAL_APP_BIN_PATH" == "$APP_BIN_PATH" ]]; then
  ./gradlew installDist || exit
fi

# execute app with JAVA_OPTS
. ./set-java-opts.sh && $APP_BIN_PATH 2>&1