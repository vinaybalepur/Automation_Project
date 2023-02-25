#!/bin/bash
sudo apt-get update

myName=vinay
if [ ! -d  "/etc/apache2" ]
then
	echo "Installing apache2 as it is missing"
	sudo apt install apache2 -y
fi

apacheStatus=$(sudo service apache2 status)
if [[ "$apacheStatus" == *"dead"* ]]
then
	echo "Starting server"
	sudo service apache2 start
fi

cd /var/log/apache2
currentTime=$(date '+%d%m%Y-%H%M%S')
fileName1=$myName-httpd-logs-$currentTime.tar
tar -cvf /tmp/$fileName1 access.log
sleep 2
currentTime=$(date '+%d%m%Y-%H%M%S')
fileName2=$myName-httpd-logs-$currentTime.tar

tar -cvf /tmp/$fileName2 error.log

aws s3 cp /tmp/$fileName1 s3://$1/$fileName1
aws s3 cp /tmp/$fileName2 s3://$1/$fileName2
