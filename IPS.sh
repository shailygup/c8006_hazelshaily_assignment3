#!/bin/sh

#download inotidy-tools to download in the background
clear
echo ' '
echo ' -------------------------------------------------------------------- '
echo 'Downloading inotify-tools for monitoring the file...'
echo ' '
dnf install inotify-tools -y
echo ' '
echo ' Download Completed '
echo ' -------------------------------------------------------------------- '
echo ' '

#User Input Section
echo 'Please specify the threshold:'
read threshold
echo 'Please specify a time limit (ex 1 minutes) or "n" for default:'
read timeLimit

#tail the secure log in the background and keep updating the secure.x
filetolog=/var/log/secure
#finds the IP users who have attempted a failed login higher than the threshold specified
loggedIPs=$(grep 'Failed password' $filetolog | grep sshd | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c | awk -v count=$threshold '{if ($1 >= count) {print $2}}')

#use inotifywait to monitor the secure log file to check for any new updates in the file
while inotifywait -e modify $filetolog; do
	#loop through the IPs found with failed attempts and blocks at firewall and sets crontab job to expire rule after set amount of time
	for IP in $(echo $loggedIPs | tr ',' '\n')
	do

		#testing for how the IPs are displayed
		# echo $IP >> Bad.txt
		#flush the table
		iptables -F
		iptables -A INPUT -s $IP -j DROP
		iptables -A OUTPUT -d $IP -j DROP
		if ["$timeLimit" != 'n']; then
			echo "iptables -D INPUT -s $IP -j DROP" | at now + $timeLimit
			echo "iptables -D OUTPUT -d $IP -j DROP" | at now + $timeLimit
		fi
	done
done
