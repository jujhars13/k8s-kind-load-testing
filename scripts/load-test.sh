#!/bin/bash
# use vegeta to load test applications
# USAGE: URL=http://foo.localhost DURATION=10s ./load-test.sh

if [[ -z "${URL}" ]]; then
  # shellcheck disable=SC2188,SC2210
  >2& echo "URL not supplied"
  exit 3
fi

declare -r duration="${DURATION:-60s}"

echo "Generating load against ${URL} for ${duration}..."

docker run --rm --network=host -v /tmp:/tmp -i jujhars13/vegeta:1.2 \
    /bin/bash -c \
    "echo 'GET ${URL}' |
        vegeta attack -rate='1' -duration='${duration}' |
        tee /tmp/results.bin |
        vegeta report"

# generate HTML report
docker run --rm  -v /tmp:/tmp -i jujhars13/vegeta:1.2 \
    /bin/bash -c \
    "cat /tmp/results.bin | vegeta plot > /tmp/plot.html"

# generate report with histogram
docker run --rm  -v /tmp:/tmp -i jujhars13/vegeta:1.2 \
    /bin/bash -c \
    "cat /tmp/results.bin | vegeta report -type=\"hist[0,100ms,200ms,300ms]\""