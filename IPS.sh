#!/bin/sh
# ln -s ~/c8006_hazelshaily_assignment3/IPS.sh /usr/local/bin
#Cron tab addition
#echo 20 10 * * * root ~/c8006_hazelshaily_assignment3/IPS.sh >> /etc/crontab

#download inotidy-tools to download in the background
clear
echo ' '
echo ' -------------------------------------------------------------------- '
echo 'Installing Dependencies...'
dnf install at -y
sudo atd
echo ' '
echo ' Install Completed '
echo ' -------------------------------------------------------------------- '
echo ' '

#User Input Section
# echo 'Please specify the threshold:'
threshold=3
# echo 'Please specify a time limit  (ex 1 or 2) or "n" for default:'
timeLimit=10
# echo 'Please specify a time metric (ex minute or hours) or "n" for default:'
# metric=minutes

#flush the table
iptables -F
iptables -X
rm Banned
#tail the secure log in the background and keep updating the secure.x
filetolog=/var/log/secure
#finds the IP users who have attempted a failed login higher than the threshold specified
# loggedIPs=$(grep 'Failed password' $filetolog | grep sshd | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c | awk -v count="$threshold" '{if ($1 >= count) {print $2}}')

#if no time limit set, block the IP forever
if [ -z $timeLimit ]; then
	$timeLimit = inifinity
fi

function timeLimitfun {
		(sleep $timeLimit
		iptables -D INPUT -s $IP -j DROP
		echo "IP unblocked")
}

#use inotifywait to monitor the secure log file to check for any new updates in the file
tail -f /var/log/secure | while read l
do
	#loop through the IPs found with failed attempts and blocks at firewall and sets crontab job to expire rule after set amount of time

	loggedIPs=$(grep 'Failed password' /var/log/secure | grep sshd | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c | awk -v count=3 '{if ($1 >= count) {print $2}} ')

	echo "$loggedIPs" >> Banned
		#testing for how the IPs are displayed
		# echo $IP >> Bad.txt
		# iptables -A INPUT -s "$IP" -j DROP
		# iptables -A OUTPUT -d "$IP" -j DROP


		if [ ! -z "$loggedIPs" ]; then
			for IP in $(echo "$loggedIPs" | tr ',' '\n')
			do
					iptables -A INPUT -s $IP -j DROP
					echo " IP is blocked"
					timeLimitfun
			done
		fi
		# sleep 1

done
