# Run gvisor syscall tests on Occlum

This repo contains scripts to run gvisor syscall tests on Occlum.  A subset of
gvisor syscall tests that can be passed when run on occlum are maintained in
folder tests. Every test suite has one file, which records the passed tests in the
corresponding test suite.

## How to build
To downlaod and build the syscall tests, run: 
```
build_tests.sh
```

## How to run
One can invoke ```run_syscall_tests_on_occlum.sh``` without any input to run all
the recorded tests in folder tests on Occlum.

To run one specific test, run:
``` 
run_syscall_tests_on_occlum.sh <TEST_SUITE> [TEST]
```

The available ```<TEST_SUITE>```s can be found in the name filed of cc_biarny in
gvisor/test/syscalls/linux/BUILD, e.g., accept_bind_stream_test and chmod_test.

```[TEST]``` is used to specify tests to run in one ```<TEST_SUITE>```. It can
contain the names of the tests which can be found in the source code of the
```<TEST_SUITE>``` in gvisor/test/syscalls/linux, e.g.,
ChmodTest.ChmodDirSucceeds and ChmodTest.FchmodFileSucceeds_NoRandomSave. When
there is no ```[TEST]```, all the tests inside ```[TEST_SUITE]``` will be run.
The syntax of ```[TEST]``` follows that of --gtest_filter from google test.
Every gvisor syscall test is supported.

To run all the syscall tests of gvisor on occlum, pass ```ALL``` as ```<TEST_SUITE>```.
It may take hours to finish all the tests and many tests may fail.
