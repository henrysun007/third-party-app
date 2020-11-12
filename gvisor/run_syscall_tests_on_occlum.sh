#!/bin/bash

set -e

suite=$1
test=$2
mode=HW

show_usage() {
    cat <<EOF

run_syscall_tests_on_occlum
Run syscall tests on occlum according to input.

USAGE:
    run_syscall_tests_on_occlum.sh [TEST_SUITE] [TEST]

    Run [TEST] in [TEST_SUITE] on occlum.
    
    Available [TEST_SUITE]s can be found in the name field of cc_library 
    in gvisor/test/syscalls/linux/BUILD, e.g., access_test, chmod_test and write_test. 
    If ALL is passed as [TEST_SUITE], all gvisor syscall tests will be run, which may 
    take hours while many tests would fail.
    
    Avaliable [TEST]s can be found in the [TEST_SUITE]-corresponding source code in 
    gvisor/test/syscalls/linux, 
    e.g., AccessTest.RelativeFile, ChmodTest.FchmodDirSucceeds_NoRandomSave and
    WriteTest.WriteNoExceedsRLimit. The syntax follows that of --gtest_filter in gtest.
    
    If no [TEST] is specified, all the tests in [TEST_SUITE] will be run.
    If no input is specified, all the tests recorded in the tests folder will be run. 
    These tests are a subset of gvisor syscall tests that are passed on occlum.

Options:
    -h      Display the usage
    --help  Display the usage

EOF
    exit 1
}

pre_run() {

    if [ -e /dev/isgx ]; then
        mode=HW
    else
        mode=SIM
    fi

    cd gvisor

    rm -rf workspace
    mkdir workspace
    cd workspace

    occlum init

    jq '.resource_limits.user_space_size = "2048MB"' Occlum.json |\
        jq '.process.default_mmap_size = "768MB"' |\
        jq '.env.default += ["TEST_TMPDIR=/tmp"]' > temp_Occlum.json
    mv temp_Occlum.json Occlum.json
}

build_all() {
    cp -R ../bazel-bin/test/syscalls/linux/* image/bin

    pushd image/bin
    rm -rf *2.params *.runfiles *.runfiles_manifest _objs exit_script rseq

    # delete test cases that hang
    rm -rf futex_test \
        socket_ip_tcp_loopback_test \
        socket_ip_udp_loopback_test \
        socket_inet_loopback_test \
        socket_ipv4_udp_unbound_external_networking_test \
        concurrency_test \
        sendfile_socket_test \
        unshare_test rename_test 
    popd

    SGX_MODE=$mode occlum build
}

build_run_suite() {
    if [ $suite == "ALL" ]; then
        build_all
        find image/bin/* | sort | sed 's/image//' | xargs -L 1 -t occlum run
    else
        cp ../bazel-bin/test/syscalls/linux/$suite image/bin
        SGX_MODE=$mode occlum build
        occlum run /bin/$suite
    fi
}

build_run_test() {
    cp ../bazel-bin/test/syscalls/linux/$suite image/bin
    SGX_MODE=$mode occlum build
    occlum run /bin/$suite --gtest_filter=$test
}

run_test() {
    suite=$1
    test=$(<$suite)
    bin=$(sed 's/..\/..\/tests/\/bin/' <<< $suite)
    occlum run ${bin} --gtest_filter=$test
}

build_run_passed() {
    build_all
    export -f run_test
    find ../../tests/* | sort | xargs -L 1 bash -c 'run_test $@' _
}

if [[ $suite == "-h" ]] || [[ $suite == "--help" ]]; then
    show_usage
fi

if [ "$#" == 0 ]; then
    pre_run
    build_run_passed
elif [ "$#" == 1 ]; then
    pre_run
    build_run_suite
elif [ "$#" == 2 ]; then
    pre_run
    build_run_test
else 
    show_usage
fi
