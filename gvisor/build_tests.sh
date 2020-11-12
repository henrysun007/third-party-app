#!/bin/bash

set -e

git submodule init
git submodule update 

cd gvisor

git apply ../remove_uncompilable_tests.diff || git apply ../remove_uncompilable_tests.diff -R --check

# occlum toolchain does not support gold linker
sed -i '/-fuse-ld=gold/d' vdso/BUILD

export CC=occlum-gcc CXX=occlum-g++

export GOPROXY=https://mirrors.aliyun.com/goproxy/

bazel build --cxxopt=-std=c++17 //test/syscalls/...

echo "tests successfully built, the output is in gvisor/bazel-bin"
