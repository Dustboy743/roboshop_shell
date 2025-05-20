#!/bin/bash

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
normal="\e[0m"
current_directory=$PWD
log_folder="/var/log/roboshop_logs"   #create a folder
file_name=$(echo $0 | cut -d "." -f1) #to extract the name
log_name="$log_folder/$file_name"
user=$(id -u)

mkdir -p $log_folder

#$(id -u)  #checking the user
if [ $user -ne 0 ]
then 
    echo -e "$red You're not the root user $normal" | tee -a $log_name
    exit 1
else
    echo -e "$green You're a root user $normal"| tee -a $log_name
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATION()
{
    if [ $1 -eq 0 ]
    then   
        echo -e "$2 is $green SUCCESS $normal" | tee -a $log_name
    else   
        echo -e "$2 is $red FAILURE $normal" | tee -a $log_name
        exit 1
    fi    
}

rm -rf /etc/yum.repos.d/mongo.repo
cp $current_directory/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATION $? "Copying MongoDB repo"

dnf install mongodb-org -y &>> $log_name
VALIDATION $? "mongo_db installation"

systemctl enable mongod &>> $log_name
VALIDATION $? "Enabling MongoDB"

systemctl start mongod &>> $log_name
VALIDATION $? "Starting MongoDB" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATION $? "Editing MongoDB conf file for remote connections"



    

