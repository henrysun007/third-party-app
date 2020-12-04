1. download, patch and build netperf
```
./build_netperf.sh
``` 

2. prepare the occlum instance for server and client
```
./prepare_client_and_server.sh
```

3. run server in occlum
```
cd server
occlum run /bin/netserver
```

3. as client cannot run in occlum due to lack of timer support in occlum, only run client in host
```
./netperf/src/netperf
```
