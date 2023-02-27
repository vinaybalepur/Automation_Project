#!/bin/bash
sudo apt-get update


myName=vinay
S3Bucket=upgrad-vinaybalepur

#This function creates and writes the content to html file. The content includes the size of the tar, time of creation
function writeToHTML()
{
      if [ ! -f /var/www/html/inventory.html ]
      then
            echo -e Log Type '\t' Time Created '\t\t' Type '\t\t' Size > /var/www/html/inventory.html
            echo -e $1 >> /var/www/html/inventory.html
            #echo -e  "httpd-logs" "\t" $currentTime "\t" "tar" "\t\t" $size >> /var/www/html/inventory.html
      else
            echo -e $1 >> /var/www/html/inventory.html
            #echo -e  "httpd-logs" "\t" $currentTime "\t" "tar" "\t\t" $size >> /var/www/html/inventory.html
      fi
}

#This function checks if apache2 is installed and running
installAndStartAapache2()
{
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
}

#This creates the tar file in /tmp folder. Also copies the tar file to S3 bucket
function_compressFileAndWriteToHTML()
{
	cd /var/log/apache2
	currentTime=$(date '+%d%m%Y-%H%M%S')
	fileName1=$myName-httpd-logs-$currentTime.tar
	tar -cvf /tmp/$fileName1 $1
	size=$(ls -lh /tmp/$fileName1 | awk '{print $5}')

	content="httpd-logs""\t "${currentTime}"\t""tar""\t\t"${size}
	writeToHTML "$content"
	copyFileToAWSBucket $2 /tmp/$fileName1 $fileName1
}

#This creates the cron file 
function createCronFile()
{
	if [ ! -f "/etc/cron.d/automation" ]
	then
		echo -e SHELL=/bin/bash '\n' PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin '\n' "0 0 * * * root /bin/bash /root/Automation_Project/Automation_Project/automation.sh" >> /etc/cron.d/automation

	fi
}

# This copies the file to S3 bucket
function copyFileToAWSBucket()
{
	aws s3 cp $2 s3://$S3Bucket/$3
}

installAndStartAapache2
createCronFile
function_compressFileAndWriteToHTML "access.log" $myName 
sleep 2
function_compressFileAndWriteToHTML "error.log" $myName


