# TP5 : P'tit cloud perso

## I. Setup DB

### 1. Install MariaDB

**🌞 Installer MariaDB sur la machine db.tp5.linux**

```bash
[tomfox@db ~]$ sudo dnf install mariadb-server
```

**🌞 Le service MariaDB**

```bash
[tomfox@db ~]$ sudo systemctl start mariadb
[tomfox@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
[tomfox@db ~]$ systemctl status mariadb
● mariadb.service - MariaDB 10.3 database server
   Loaded: loaded (/usr/lib/systemd/system/mariadb.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-11-25 11:28:48 CET; 8s ago
     Docs: man:mysqld(8)
           https://mariadb.com/kb/en/library/systemd/
  Process: 5707 ExecStartPost=/usr/libexec/mysql-check-upgrade (code=exited, status=0/SUCCESS)
  Process: 5572 ExecStartPre=/usr/libexec/mysql-prepare-db-dir mariadb.service (code=exited, status=0/SUCCESS)
  Process: 5548 ExecStartPre=/usr/libexec/mysql-check-socket (code=exited, status=0/SUCCESS)
 Main PID: 5675 (mysqld)
   Status: "Taking your SQL requests now..."
    Tasks: 30 (limit: 11397)
   Memory: 79.7M
   CGroup: /system.slice/mariadb.service
           └─5675 /usr/libexec/mysqld --basedir=/usr

Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: See the MariaDB Knowledgebase at http://mariadb.com/kb or the
Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: MySQL manual for more instructions.
Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: Please report any problems at http://mariadb.org/jira
Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: The latest information about MariaDB is available at http://mariadb.org/.
Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: You can find additional information about the MySQL part at:
Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: http://dev.mysql.com
Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: Consider joining MariaDB s strong and vibrant community:
Nov 25 11:28:47 db.tp5.linux mysql-prepare-db-dir[5572]: https://mariadb.org/get-involved/
Nov 25 11:28:47 db.tp5.linux mysqld[5675]: 2021-11-25 11:28:47 0 [Note] /usr/libexec/mysqld (mysqld 10.3.28-MariaDB) starting as process 5675 ...
Nov 25 11:28:48 db.tp5.linux systemd[1]: Started MariaDB 10.3 database server.
[tomfox@db ~]$ sudo ss -ltnp | grep mysqld
LISTEN 0      80                 *:3306            *:*    users:(("mysqld",pid=5675,fd=21))
[tomfox@db ~]$ ps -aux | grep mysqld
mysql       5675  0.0  4.5 1296832 85376 ?       Ssl  11:28   0:00 /usr/libexec/mysqld --basedir=/usr
```

**🌞 Firewall**

```bash
[tomfox@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[tomfox@db ~]$ sudo firewall-cmd --reload
success
```

### 2. Conf MariaDB

**🌞 Configuration élémentaire de la base**

```bash
[tomfox@db ~]$ mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...
```
Ici on fait entrer car nous venons tout juste d'installer MariaDB donc nous n'avons aucun mot de pass pour l'utilisateur root

```bash
Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] Y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!
```
Je choisis de mettre un mot de pass pour l'utilsateur root (de MariaDB)
pour évité tout problème de sécu

```ash
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!
```
C'est un énorme problème de sécu il faut absolument retirer l'user anonymous

```bash
Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!
```
On désactive pour plein de raison comme le brute force ou les botnet

```bash
By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!
```
On retire cette db car nous allons utiliser MariaDB pour une vrai prod
et elle nous sert à rien

```bash
Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
```
Ici nous accept que nos changement prenne effet

**🌞 Préparation de la base en vue de l'utilisation par NextCloud**

```bash
[tomfox@db ~]$ sudo mysql -u root -p
[sudo] password for tomfox: 
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 18
Server version: 10.3.28-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.5.1.11' IDENTIFIED BY 'mdpweb';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.5.1.11';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
```

### 3. Test

**🌞 Installez sur la machine web.tp5.linux la commande mysql**

```bash
[tomfox@web ~]$ sudo dnf provides mysql
Last metadata expiration check: 0:16:35 ago on Thu 25 Nov 2021 11:44:40 AM CET.
mysql-8.0.26-1.module+el8.4.0+652+6de068a7.x86_64 : MySQL client programs and shared libraries
Repo        : appstream
Matched from:
Provide    : mysql = 8.0.26-1.module+el8.4.0+652+6de068a7
[tomfox@web ~]$ sudo dnf install mysql
```

**🌞 Tester la connexion**

```bash
[tomfox@web ~]$ mysql -h 10.5.1.12 -P 3306 -u 'nextcloud' -p nextcloud
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 5.5.5-10.3.28-MariaDB MariaDB Server

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW TABLES;
Empty set (0.00 sec)
```

## II. Setup Web

### 1. Install Apache


**🌞 Installer Apache sur la machine db.tp5.linux**

```bash
[tomfox@web ~]$ sudo dnf install httpd
```

**🌞 Analyse du service Apache**

```bash
[tomfox@web ~]$ sudo systemctl start httpd
[tomfox@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[tomfox@web ~]$ ps -aux | grep httpd
root        4141  0.0  0.6 280220 11308 ?        Ss   12:24   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4142  0.0  0.4 294104  8480 ?        S    12:24   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4143  0.0  0.6 1351892 12100 ?       Sl   12:24   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4144  0.0  0.7 1483020 14148 ?       Sl   12:24   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4145  0.0  0.6 1351892 12100 ?       Sl   12:24   0:00 /usr/sbin/httpd -DFOREGROUND
[tomfox@web ~]$ sudo ss -laputen | grep httpd
tcp   LISTEN 0      128                   *:80              *:*     users:(("httpd",pid=4145,fd=4),("httpd",pid=4144,fd=4),("httpd",pid=4143,fd=4),("httpd",pid=4141,fd=4)) ino:33846 sk:3 v6only:0 <->
[tomfox@web ~]$ ps -aux | grep httpd
root        4405  0.6  0.6 280220 11388 ?        Ss   12:29   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4407  0.0  0.4 294104  8352 ?        S    12:29   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4408  0.0  0.7 1483020 14148 ?       Sl   12:29   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4409  0.0  0.8 1351892 16188 ?       Sl   12:29   0:00 /usr/sbin/httpd -DFOREGROUND
apache      4410  0.0  0.8 1351892 16188 ?       Sl   12:29   0:00 /usr/sbin/httpd -DFOREGROUND
```
C'est utilisateur Apache

**🌞 Un premier test**

```bash
[tomfox@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
[sudo] password for tomfox: 
success
[tomfox@web ~]$ sudo firewall-cmd --reload
success
❯ curl http://10.5.1.11/
<!doctype html>
```

**🌞 Installer PHP**

```bash
[tomfox@db ~]$ sudo dnf install epel-release
[...]
Complete!
[tomfox@db ~]$ sudo dnf update
[...]
Complete!
[tomfox@db ~]$ sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
[...]
Complete!
[tomfox@db ~]$ sudo dnf module enable php:remi-7.4
[...]
Complete!
[tomfox@db ~]$ sudo dnf install zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp
[...]
Complete!
```
b
