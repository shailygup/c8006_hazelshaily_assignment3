
#!/bin/sh


echo Please specify the threshold:
read threshold
# echo 'Please specify a time limit:'
# read timeLimit

# file=`tail -f /var/log/secure`
filetolog=/var/log/secure

#finds the IP of location failed ssh attempts and prints the number of failed attempts
loggedIPs=`grep -i 'Failed password'  $filetolog | grep sshd | awk '{print $11}' | sort | uniq -c | awk -v count=$threshold '{if ($1 >= count) {print $2}}'`

for IP in $loggedIPs
do
    iptables -A INPUT -s $IP -j DROP
    iptables -A OUTPUT -d $IP -j DROP
    echo "iptables -D INPUT -s $IP -j DROP" | at now + 1 minutes
    echo "iptables -D OUTPUT -d $IP -j DROP" | at now + 1 minutes
done



#----thought----#
#since the above cmd is able to count the number of failed attempts, we can make a loop that says if >=3 attempts, then block the ip

#just added here for reference
#iptables -A INPUT  -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --name DEFAULT --r source -j DROP
