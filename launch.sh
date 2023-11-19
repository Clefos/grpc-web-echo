#!/bin/bash

# Start the echo-grpc server
./application &

# Start the envoy grpc web proxy
/usr/local/bin/envoy -c /etc/envoy/envoy.yaml -l trace --log-path /tmp/envoy_info.log &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?
