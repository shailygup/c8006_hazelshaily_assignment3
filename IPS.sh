#!/bin/bash

threshold=3
count=1

#monitor the /var/log/security file for any failed authentication errors
grep -i "authentication failure" /var/log/secure | awk '{ print $13 }' | cut -b7-  | sort | uniq -c
#grep 'Failed password' /var/log/secure* | grep sshd | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c



#finds the IP of location failed ssh attempts and prints the number of failed attempts
grep -i 'Failed password'  /var/log/secure* | grep sshd | awk '{print $11}' | sort | uniq -c

#----thought----#
#since the above cmd is able to count the number of failed attempts, we can make a loop that says if >=3 attempts, then block the ip

#just added here for reference
#iptables -A INPUT  -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --name DEFAULT --r source -j DROP