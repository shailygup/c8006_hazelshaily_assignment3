#!/bin/bash

clear

attackingIP=184.68.138.20,192.1689.0.4

echo 'Testing the monitoring Application ...'

for IP in $(echo $attackingIP | tr ',' '\n')
do
	time=$((RANDOM % 10 + 1))

	sleep $time 
done