#!/usr/bin/env bats

#!/usr/bin/env bats

: ${BRANCH:=edge}
VER=${BRANCH#v}
TAG=${VER}
REPO=${REPO}

@test "supervisord installed" {

  run docker run --rm $REPO:$TAG sh -c 'apk list 2> /dev/null | grep -q supervisor'
  [ $status -eq 0 ]
}

@test "test supervisord starting crond and rsyslogd" {

  run ./tests/supervisor-test.sh $REPO:$TAG
  [ $status -eq 0 ]
}
