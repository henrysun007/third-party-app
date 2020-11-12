#!/bin/bash

OCCLUM_MUSL_DIR=/usr/local/occlum/x86_64-linux-musl

set -e

git clone https://github.com/linux-test-project/ltp.git
cd ltp

# the latest commit when this sctript was composed
git checkout c467c5bd20162d0f92e97da17f83c1a6207980cf

# hack main process to remove fork
git apply ../main_process_fork_hack.diff

# delete test cases that cannot be compiled with musl libc
# copied from /travis/alpine.sh
rm -rfv \
	testcases/kernel/sched/process_stress/process.c \
	testcases/kernel/syscalls/confstr/confstr01.c \
	testcases/kernel/syscalls/fmtmsg/fmtmsg01.c \
	testcases/kernel/syscalls/getcontext/getcontext01.c \
	testcases/kernel/syscalls/getdents/getdents01.c \
	testcases/kernel/syscalls/getdents/getdents02.c \
	testcases/kernel/syscalls/rt_tgsigqueueinfo/rt_tgsigqueueinfo01.c \
	testcases/kernel/syscalls/timer_create/timer_create01.c \
	testcases/kernel/syscalls/timer_create/timer_create03.c \
	utils/benchmark/ebizzy-0.3

# cannot be compiled locally
rm -rfv testcases/kernel/syscalls/setsockopt/setsockopt03.c

make autotools
./configure CXX=occlum-g++ CC=occlum-gcc CXXFLAGS=-I$OCCLUM_MUSL_DIR/include CFLAGS=-I$OCCLUM_MUSL_DIR/include --prefix=$OCCLUM_MUSL_DIR/ltp LDFLAGS=-L$OCCLUM_MUSL_DIR/lib
make -j
sudo make install
echo "ltp installed successfully in $OCCLUM_MUSL_DIR/ltp"
