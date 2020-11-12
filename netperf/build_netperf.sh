#!/bin/bash

set -e

git submodule init
git submodule update 

cd netperf 

git apply ../remove_fork.patch || git apply ../remove_fork.patch -R --check

./autogen.sh
./configure CXX=occlum-g++ CC=occlum-gcc

make -j4

echo "netperf successfully built, the output is in netperf/src"

