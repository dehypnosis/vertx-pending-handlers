#!/usr/bin/env bash

# enter into current module directory; for dumb sentry configuration loader
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# do not include tab or space in property values
APP_PROFILE="${APP_PROFILE:-LOCAL}"
CFG_PATH="$(echo "conf/${APP_PROFILE}" | awk '{print tolower($0)}')"

export JAVA_OPTS="\
    ${JVM_MEMORY}\
    -server \
    -XX:-MaxFDLimit \
    -XX:-UsePerfData -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:G1HeapRegionSize=8m -XX:+ParallelRefProcEnabled \
    -XX:-ResizePLAB -XX:+UseThreadPriorities \
    --illegal-access=deny \
    -Dfile.encoding=UTF8 \
    -Duser.timezone=Asia/Seoul \
    -Dsun.net.inetaddr.ttl=0 \
    -Djava.net.preferIPv4Stack=true \
    -Dvertx.logger-delegate-factory-class-name=io.vertx.core.logging.Log4j2LogDelegateFactory \
    -DLog4jContextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector \
    -DAsyncLogger.WaitStrategy=busyspin \
    -Dlog4j2.enable.threadlocals=true \
    -Dlog4j2.enable.direct.encoders=true \
    -Dlog4j.configurationFile=${CFG_PATH}/log4j2.xml \
    -Dsentry.properties.file=${CFG_PATH}/sentry.properties \
    -Dapp.profile=${APP_PROFILE:-LOCAL}"

echo "$JAVA_OPTS" > ./set-java-opts.out
