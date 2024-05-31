#/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.nevanth.online

TIMESTAMP=$(date +%F)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started execting at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...... $R FAILED $N"
    else
        echo -e "$2 ...... $G SUCCESS $N"
    fi
}


if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR :: Please run this script with root access $N"
    exit 1
else
    echo "you are root user"
fi

dnf module disable nodejs -y
VALIDATE $? "DISABLING CURRENT NODEJS"

dnf module enable nodejs:18 -y
VALIDATE $? "ENNABLING NODEJS:18"

dnf install nodejs -y
VALIDATE $? "INSTALLING NODEJS:18"

useradd roboshop
VALIDATE $? "CREATING ROBOSHOP USER"

mkdir /app
VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "DOWNLOADING CATALOGUE APPLICATION"

cd /app 
VALIDATE $? "CREATING APP DIRECTORY"

unzip /tmp/catalogue.zip
VALIDATE $? "UNZIPPING CATALOGUE"

npm install 
VALIDATE $? "INSTALLING DEPENDENCIES"

CP /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "COPYING CATALOGUE SERVICE FILE"

systemctl daemon-reload
VALIDATE $? "CATALOGUE DAEMON RELOAD"

systemctl enable catalogue
VALIDATE $? "ENABLING CATALOGUE"

systemctl start catalogue
VALIDATE $? "STARTING CATALOGUE"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y
VALIDATE $? "INSTALLING MONGODB CLIENT"

mongo --host $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "FINISHED"                                                         