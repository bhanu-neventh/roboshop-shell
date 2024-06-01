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
        exit 1
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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "DISABLING CURRENT NODEJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "ENNABLING NODEJS:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "INSTALLING NODEJS:18"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "ROBOSHOP USER CREATION"
else
    echo -e "ROBOSHOP USER ALREADY EXIT $Y SKKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "DOWNLOADING CATALOGUE APPLICATION"

cd /app &>> $LOGFILE
VALIDATE $? "CREATING APP DIRECTORY"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "UNZIPPING CATALOGUE"

npm install &>> $LOGFILE
VALIDATE $? "INSTALLING DEPENDENCIES"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "COPYING CATALOGUE SERVICE FILE"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "CATALOGUE DAEMON RELOAD"
 
systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "ENABLING CATALOGUE"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "STARTING CATALOGUE"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE 
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "INSTALLING MONGODB CLIENT"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "FINISHED"                                                         