
## Step-by-Step Instructions

### Step 1. Install MySQL Server

```bash
sudo apt update
sudo apt install mysql-server -y
````

---

### Step 2. Secure MySQL (Optional but Recommended)

```bash
sudo mysql_secure_installation
```

You can skip this or configure:

* Press `Enter` to skip root password setup (or set if prompted)
* Remove anonymous users → Yes
* Disallow remote root login → No
* Remove test DB → Yes
* Reload privilege tables → Yes

---

### Step 3. Log in to MySQL as Root

```bash
sudo mysql
```

Then inside the MySQL shell, run:

```sql
-- Create user 'siva' with password
CREATE USER 'siva'@'%' IDENTIFIED BY 'YOUR_OWN_PASSWORD';

-- Grant all permissions
GRANT ALL PRIVILEGES ON *.* TO 'siva'@'%' WITH GRANT OPTION;

-- Save changes
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

---

### Step 4. Allow Remote Connections

Edit the MySQL config:

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Look for:

```
bind-address = 127.0.0.1
```

Change it to:

```
bind-address = 0.0.0.0
```

Save and exit: `Ctrl+O`, `Enter`, `Ctrl+X`

---

### Step 5. Restart MySQL

```bash
sudo systemctl restart mysql
```

---

### Step 6. Allow Port 3306 in Cloud Firewall

Open **port 3306** to all IPs (`0.0.0.0/0`) in:

* GCP → VPC Network → Firewall rules
* AWS → Security Groups
* Azure → NSG (Network Security Groups)

---

### Step 7. Test Remote Connection

From your local or any remote machine:

```bash
mysql -u siva -p -h <your-server-ip>
# Enter password: YOUR_OWN_PASSWORD
```

---

### Step 8. Create Database, Table & Insert Records

#### 🔹 Log in to MySQL as User `siva`

```bash
mysql -u siva -p -h <your-server-ip>
```

#### 🔹 Create a Database

```sql
CREATE DATABASE i27academy;
```

#### 🔹 Use the Database

```sql
USE i27academy;
```

#### 🔹 Create a Table

```sql
CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  course VARCHAR(100)
);
```

#### 🔹 Insert Records

```sql
INSERT INTO students (name, email, course)
VALUES 
('John Doe', 'john@example.com', 'DevOps'),
('Sita Rani', 'sita@example.com', 'GCP'),
('Ravi Kumar', 'ravi@example.com', 'Terraform');
```

#### 🔹 View All Records

```sql
SELECT * FROM students;
```

Expected Output:

```
+----+------------+------------------+------------+
| id | name       | email            | course     |
+----+------------+------------------+------------+
|  1 | John Doe   | john@example.com | DevOps     |
|  2 | Sita Rani  | sita@example.com | GCP        |
|  3 | Ravi Kumar | ravi@example.com | Terraform  |
+----+------------+------------------+------------+
```

---
### Step 9. Implement DMS

### Step 10: Few more records after migation 
* The below records will be useful to test read and write transcations after dms is completed

```sql
INSERT INTO students (name, email, course)
VALUES 
('Amit Sharma', 'amit.sharma@example.com', 'Docker & Kubernetes'),
('Priya Nair', 'priya.nair@example.com', 'Cloud Security'),
('Rahul Verma', 'rahul.verma@example.com', 'Azure DevOps'),
('Neha Singh', 'neha.singh@example.com', 'Python for Automation'),
('Karthik Reddy', 'karthik.reddy@example.com', 'Linux Fundamentals');
```
