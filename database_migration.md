# Create Database Migration


## Create and connect  Onprim Mysql
```bash
gcloud compute instances create onprim-mysql-new --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20211115 --zone us-central1-a

# Perform the following actions to install mysql
sudo apt update
sudo apt install mysql-server -y
sudo mysql_secure_installation


Validate ===== y
Enter Password
emove anonymous users?  ==== n
Disallow root login remotely?  ==== n
Remove test database and access to it? ===== y
Reload privilege tables now? ===== y

# Enter into mysql terminal 
mysql

# Create a database
create database emp;

# Switch to the db created
use emp;

# Create a table
CREATE TABLE Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);

# Insert into tables
INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("1","Siva","M","Hyderabad","Telangana");

SELECT user,authentication_string,plugin,host FROM mysql.user;

CREATE USER 'siva'@'104.154.172.109' IDENTIFIED BY 'Gcp@20232023';
grant all on *.* to 'siva'@'104.154.172.109';
flush privileges;

GRANT ALL PRIVILEGES ON *.* TO 'siva'@'%' IDENTIFIED BY 'Gcp@20232023' WITH GRANT OPTION;
flush privileges;


# Try to connect to mysql instance from anywhere 
mysql -u siva -h PUBLICIPOFVM -p

# If we get below error : 
ERROR 2003 (HY000): Can't connect to MySQL server on '34.125.93.52:3306' (111)

vi /etc/mysql/mysql.conf.d/mysqld.cnf
comment the below line
#bind-address           = 127.0.0.1

# During the test process, if we get the error , perform the below steps on MYSQL VM(GCE)
```bash
# the below is the error
MySQL binlog is configured incorrectly on the source database. Check that the configuration follows the MySQL documentation.
```bash
vi /etc/mysql/mysql.conf.d/mysql.cnf

[mysqld]
log-bin=mysql-bin
server-id=1

systemctl restart mysql.service
```
