#!/bin/bash

threshold=3
count=1

#monitor the /var/log/security file for any failed authentication errors, one or the other
grep "authentication failure" /var/log/secure | awk '{ print $13 }' | cut -b7-  | sort | uniq -c
grep 'Failed password' /var/log/secure* | grep sshd | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort |



