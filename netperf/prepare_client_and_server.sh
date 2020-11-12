#!/bin/bash

set -e

rm -rf client server

# client cannot run in occlum for the lack of setitimer in occlum
#occlum new client
#cp netperf/src/netperf client/image/bin
#pushd client
#occlum build
#popd

occlum new server
cp netperf/src/netserver server/image/bin
pushd server
occlum build
popd
