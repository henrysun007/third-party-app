#!/bin/bash

OCCLUM_MUSL_DIR=/usr/local/occlum/x86_64-linux-musl

set -e

cp -R $OCCLUM_MUSL_DIR/ltp .

cd ltp
occlum init
cp -R testcases/bin/* image/bin
cp -R testcases/data image
jq '.vm.user_space_size = "1024MB"' Occlum.json > temp_Occlum.json
jq '.process.default_mmap_size = "768MB"' temp_Occlum.json > Occlum.json
occlum build

export LTPROOT=${PWD} TMPBASE=/tmp TMPDIR=/tmp
cat ../testcases.list | sed -e 's/^/\/bin\//' | xargs -L 1 -t occlum run
