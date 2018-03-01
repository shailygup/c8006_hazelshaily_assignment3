#!/bin/sh

echo Please specify the threshold:
read threshold
echo 'Please specify a time limit (ex 1 minutes):'
read timeLimit

# file=`tail -f /var/log/secure`
filetolog=/var/log/secure

#finds the IP of location failed ssh attempts and prints the number of failed attempts
loggedIPs=`grep -i 'Failed password'  $filetolog | grep sshd | awk '{print $11}' | sort | uniq -c | awk -v count=$threshold '{if ($1 >= count) {print $2}}'`

#loop through the IPs found with failed attempts and blocks at firewall and sets crontab job to expire rule after set amount of time
for IP in $loggedIPs
do
	iptables -A INPUT -s $IP -j DROP
	iptables -A OUTPUT -d $IP -j DROP
    if [ ! -z "$timeLimit" ]; then
    	#The time limit for blocking the IP. The default setting will be block indefinitely. 
    	echo "iptables -D INPUT -s $IP -j DROP" | at now + $timeLimit
    	echo "iptables -D OUTPUT -d $IP -j DROP" | at now + $timeLimit
    fi
done



#----thought----#
#since the above cmd is able to count the number of failed attempts, we can make a loop that says if >=3 attempts, then block the ip

#just added here for reference
#iptables -A INPUT  -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --name DEFAULT --r source -j DROP
