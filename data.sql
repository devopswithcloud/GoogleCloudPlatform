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

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("2","Johb","h","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("3","Doe","J","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("4","Smith","K","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("5","Doe","J","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("6","Smith","K","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("7","Doe","J","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("8","Smith","K","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("9","Doe","J","Hyderabad","Telangana");

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("10","Smith","K","Hyderabad","Telangana");
