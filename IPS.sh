#!/bin/sh

#download inotidy-tools to download in the background
dnf install inotify-tools -y

#User Input Section
echo Please specify the threshold:
read threshold
echo 'Please specify a time limit (ex 1 minutes):'
read timeLimit

#tail the secure log in the background and keep updating the secure.x
filetolog=/var/log/secure
#finds the IP of location failed ssh attempts and prints the number of failed attempts
loggedIPs=$(grep -i 'Failed password'  $filetolog | grep sshd | awk '{print $11}' | sort | uniq -c | awk -v count=$threshold '{if ($1 >= count) {print $2}}'

#use inotifywait to monitor the secure log file to check for any new updates in the file
while inotifywait -e modify $filetolog; do
	#loop through the IPs found with failed attempts and blocks at firewall and sets crontab job to expire rule after set amount of time
	for IP in $(echo $loggedIPs | tr ',' '\n')
	do
		echo $IP >> Bad.txt
		iptables -F
		iptables -A INPUT -s $IP -j DROP
		iptables -A OUTPUT -d $IP -j DROP
		if [["$timeLimit" != none]] then
			echo "iptables -D INPUT -s $IP -j DROP" | at now + $timeLimit
			echo "iptables -D OUTPUT -d $IP -j DROP" | at now + $timeLimit
		fi
	done
done



#----thought----#
#since the above cmd is able to count the number of failed attempts, we can make a loop that says if >=3 attempts, then block the ip

#just added here for reference
#iptables -A INPUT  -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --name DEFAULT --r source -j DROP
