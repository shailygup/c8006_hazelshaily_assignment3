#!/bin/bash

clear

goodIP=192.168.0.10

echo 'Testing the monitoring Application ...'

for IP in $goodIP
do
	time=$((RANDOM % 10 + 1))
  ssh $IP
	sleep $time
done
