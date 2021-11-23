# TP4 : Une distribution orientée serveur

## II. Checklist

➜ Configuration IP statique

**🌞 Choisissez et définissez une IP à la VM**

```bash
[tomfox@localhost ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
TYPE=Ethernet
BOOTPROTO=static
NAME=enp0s8
DEVICE=enp0s8
ONBOOT=yes
IPADDR=192.168.58.37
NETMASK=255.255.255.0
[tomfox@localhost ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:35:4e:85 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 85424sec preferred_lft 85424sec
    inet6 fe80::a00:27ff:fe35:4e85/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:98:a9:ae brd ff:ff:ff:ff:ff:ff
    inet 192.168.58.37/24 brd 192.168.58.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe98:a9ae/64 scope link 
       valid_lft forever preferred_lft forever
```

➜ Connexion SSH fonctionnelle

```bash
[tomfox@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2021-11-23 11:17:36 CET; 32min ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 857 (sshd)
    Tasks: 1 (limit: 11397)
   Memory: 3.9M
   CGroup: /system.slice/sshd.service
           └─857 /usr/sbin/sshd -D -oCiphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes256-cbc,aes128->

Nov 23 11:17:36 localhost.localdomain sshd[857]: Server listening on 0.0.0.0 port 22.
Nov 23 11:17:36 localhost.localdomain sshd[857]: Server listening on :: port 22.
Nov 23 11:17:36 localhost.localdomain systemd[1]: Started OpenSSH server daemon.
Nov 23 11:26:47 localhost.localdomain sshd[1646]: Accepted password for tomfox from 192.168.58.1 port 42668 ssh2
Nov 23 11:26:47 localhost.localdomain sshd[1646]: pam_unix(sshd:session): session opened for user tomfox by (uid=0)
Nov 23 11:37:55 localhost.localdomain sshd[1727]: Accepted password for tomfox from 192.168.58.1 port 42674 ssh2
Nov 23 11:37:55 localhost.localdomain sshd[1727]: pam_unix(sshd:session): session opened for user tomfox by (uid=0)
Nov 23 11:37:55 localhost.localdomain sshd[1727]: pam_unix(sshd:session): session closed for user tomfox
Nov 23 11:38:04 localhost.localdomain sshd[1753]: Accepted publickey for tomfox from 192.168.58.1 port 42676 ssh2: RSA SHA256:U>
Nov 23 11:38:04 localhost.localdomain sshd[1753]: pam_unix(sshd:session): session opened for user tomfox by (uid=0)
```

```bash
❯ cat .ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6A9oloL1mkXvMcHF+uQZijgRpZ8Riuvb3vKbhiFiwdY1BX52GXOSylx28wgZnC5G9x3leGZrOBZpi2padqtjJ8AVPhre02niMwGAywCbiSLFFIdwKeGpcNDVZDpV7210HGPj94U6mfqUsvPHXsu9tyF0QxVQaoDo2ryoA0ieLF9LufeLpiaHAxaq76IHdC5lEs97ujh9QLtoi3C3tvKN/+Lxuxqa2zlGTnXdhxpvTs6NihBglxU02FW/3tTytZ0cNuset/WaVQ7Xremr7ifmAs+9nNFibDtYRNHpFQ1l5E6erS+jkLVuurry/oWCkRoh3VAX1XuEkasDENP2aQzbqvNDo8aDji0fsWATyhN9bgUpUXFvEfii2gFqqOgD/yZ+fF6dukv6pmzh5T3kokk/76LJCl0JT9I85bpup9KiM0WT+YDsS658mjFDlyPWqX6crqXfWzu9WRcQ28HA3E1ikOO4n1IaPClnfn8Ct+YuajCjEnvxdDBE2U0mOmrIz7DfewYG3HVu5cVI5tDYtFciKLlTNg2NP31ntiQNJitTQcl2iPB84H8WUXEPA/HpvqYp6wI8TNN21f6uvgy/HY6Qp9jz6C42ccFf47/FJyg7KQcC/2KSKTm9GOTInJVJN7gXUW5YnCfBCFRoYD9uF+ENFImM0FMNGdB9UdgzemeHtZQ== tomfox@ZenBook
❯ ssh-copy-id -i ~/.ssh/id_rsa.pub tomfox@192.168.58.37
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/tomfox/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to ilter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
tomfox@192.168.58.37's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'tomfox@192.168.58.37'"
and check to make sure that only the key(s) you wanted were added.

❯ ssh tomfox@192.168.58.37
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Tue Nov 23 11:26:47 2021 from 192.168.58.1
[tomfox@localhost ~]$ cat .ssh/authorized_keys 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6A9oloL1mkXvMcHF+uQZijgRpZ8Riuvb3vKbhiFiwdY1BX52GXOSylx28wgZnC5G9x3leGZrOBZpi2padqtjJ8AVPhre02niMwGAywCbiSLFFIdwKeGpcNDVZDpV7210HGPj94U6mfqUsvPHXsu9tyF0QxVQaoDo2ryoA0ieLF9LufeLpiaHAxaq76IHdC5lEs97ujh9QLtoi3C3tvKN/+Lxuxqa2zlGTnXdhxpvTs6NihBglxU02FW/3tTytZ0cNuset/WaVQ7Xremr7ifmAs+9nNFibDtYRNHpFQ1l5E6erS+jkLVuurry/oWCkRoh3VAX1XuEkasDENP2aQzbqvNDo8aDji0fsWATyhN9bgUpUXFvEfii2gFqqOgD/yZ+fF6dukv6pmzh5T3kokk/76LJCl0JT9I85bpup9KiM0WT+YDsS658mjFDlyPWqX6crqXfWzu9WRcQ28HA3E1ikOO4n1IaPClnfn8Ct+YuajCjEnvxdDBE2U0mOmrIz7DfewYG3HVu5cVI5tDYtFciKLlTNg2NP31ntiQNJitTQcl2iPB84H8WUXEPA/HpvqYp6wI8TNN21f6uvgy/HY6Qp9jz6C42ccFf47/FJyg7KQcC/2KSKTm9GOTInJVJN7gXUW5YnCfBCFRoYD9uF+ENFImM0FMNGdB9UdgzemeHtZQ== tomfox@ZenBook
```
On peut voir que c'est la même clé publique

➜ Accès internet

**🌞 Prouvez que vous avez un accès internet**

```bash
[tomfox@localhost ~]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=63 time=23.10 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=63 time=24.8 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=63 time=24.6 ms
64 bytes from 1.1.1.1: icmp_seq=4 ttl=63 time=23.7 ms
64 bytes from 1.1.1.1: icmp_seq=5 ttl=63 time=24.7 ms
64 bytes from 1.1.1.1: icmp_seq=6 ttl=63 time=24.6 ms
^C
--- 1.1.1.1 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5010ms
rtt min/avg/max/mdev = 23.717/24.381/24.779/0.430 ms
```

**🌞 Prouvez que vous avez de la résolution de nom**

```bash
[tomfox@localhost ~]$ ping fbi.gov
PING fbi.gov (104.16.148.244) 56(84) bytes of data.
64 bytes from 104.16.148.244 (104.16.148.244): icmp_seq=1 ttl=63 time=26.8 ms
64 bytes from 104.16.148.244 (104.16.148.244): icmp_seq=2 ttl=63 time=27.10 ms
64 bytes from 104.16.148.244 (104.16.148.244): icmp_seq=3 ttl=63 time=28.1 ms
^C
--- fbi.gov ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 26.812/27.627/28.090/0.578 ms
```

➜ Nommage de la machine

**🌞 Définissez `node1.tp4.linux` comme nom à la machine**

```bash
[tomfox@localhost ~]$ cat /etc/hostname
node1.tp4.linux
[tomfox@localhost ~]$ hostname
node1.tp4.linux
```

## III. Mettre en place un service


**🌞 Installez NGINX en vous référant à des docs online**

```
[tomfox@localhost ~]$ sudo dnf install nginx
```
```bash
[tomfox@localhost ~]$ sudo systemctl start nginx
[tomfox@localhost ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-11-23 12:09:58 CET; 3s ago
  Process: 5307 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 5306 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 5304 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 5309 (nginx)
    Tasks: 2 (limit: 11397)
   Memory: 6.7M
   CGroup: /system.slice/nginx.service
           ├─5309 nginx: master process /usr/sbin/nginx
           └─5310 nginx: worker process

Nov 23 12:09:58 node1.tp4.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Nov 23 12:09:58 node1.tp4.linux nginx[5306]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Nov 23 12:09:58 node1.tp4.linux nginx[5306]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Nov 23 12:09:58 node1.tp4.linux systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Nov 23 12:09:58 node1.tp4.linux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
On voit bien que le service est installer et lancer


**🌞 Analysez le service NGINX**

```bash
[tomfox@localhost ~]$ ps -aux | grep nginx
nginx       5310  0.0  0.4 151820  8068 ?        S    12:09   0:00 nginx: worker process
```
L'utilisateur qui fait tourner le processus du service NGINX est user nginx

```bash
tomfox@localhost ~]$ sudo ss -ltpn  | grep nginx
LISTEN 0      128          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=5310,fd=8),("nginx",pid=5309,fd=8))
LISTEN 0      128             [::]:80           [::]:*    users:(("nginx",pid=5310,fd=9),("nginx",pid=5309,fd=9))
[tomfox@localhost ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;
[tomfox@localhost ~]$ ls -la /usr/share/nginx/html
total 20
drwxr-xr-x. 2 root root   99 Nov 23 12:08 .
drwxr-xr-x. 4 root root   33 Nov 23 12:08 ..
-rw-r--r--. 1 root root 3332 Jun 10 11:09 404.html
-rw-r--r--. 1 root root 3404 Jun 10 11:09 50x.html
-rw-r--r--. 1 root root 3429 Jun 10 11:09 index.html
-rw-r--r--. 1 root root  368 Jun 10 11:09 nginx-logo.png
-rw-r--r--. 1 root root 1800 Jun 10 11:09 poweredby.png
```

## 4. Visite du service web

**🌞 Configurez le firewall pour autoriser le trafic vers le service NGINX**

```bash
[tomfox@localhost ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[tomfox@localhost ~]$ sudo firewall-cmd --reload
success
```

**🌞 Tester le bon fonctionnement du service**

```bash
❯ curl http://192.168.58.37/
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
```

## 5. Modif de la conf du serveur web

**🌞 Changer le port d'écoute**

```bash
[tomfox@localhost ~]$ cat /etc/nginx/nginx.conf | grep listen
        listen       8080 default_server;
        listen       [::]:8080 default_server;
```

```bash
[tomfox@localhost ~]$ sudo systemctl restart nginx
[tomfox@localhost ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-11-23 12:41:35 CET; 5s ago
  Process: 5545 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 5543 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 5541 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 5547 (nginx)
    Tasks: 2 (limit: 11397)
   Memory: 3.7M
   CGroup: /system.slice/nginx.service
           ├─5547 nginx: master process /usr/sbin/nginx
           └─5548 nginx: worker process

Nov 23 12:41:35 node1.tp4.linux systemd[1]: nginx.service: Succeeded.
Nov 23 12:41:35 node1.tp4.linux systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Nov 23 12:41:35 node1.tp4.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Nov 23 12:41:35 node1.tp4.linux nginx[5543]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Nov 23 12:41:35 node1.tp4.linux nginx[5543]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Nov 23 12:41:35 node1.tp4.linux systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Nov 23 12:41:35 node1.tp4.linux systemd[1]: Started The nginx HTTP and reverse proxy server.
[tomfox@localhost ~]$ 

```

```bash
[tomfox@localhost ~]$ sudo ss -lptn | grep nginx
LISTEN 0      128          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=5548,fd=8),("nginx",pid=5547,fd=8))
LISTEN 0      128             [::]:8080         [::]:*    users:(("nginx",pid=5548,fd=9),("nginx",pid=5547,fd=9))
```

```bash
[tomfox@localhost ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[tomfox@localhost ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[tomfox@localhost ~]$ sudo firewall-cmd --reload
success
```

```bash
❯ curl http://192.168.58.37/
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
```

**🌞 Changer l'utilisateur qui lance le service**

```bash
[tomfox@localhost ~]$ sudo useradd web -m -s /bin/bash -u 2000
[tomfox@localhost ~]$ sudo passwd web
Changing password for user web.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.
[tomfox@localhost ~]$ cat /etc/passwd | grep web
web:x:2000:2000::/home/web:/bin/bash
```

```bash
[tomfox@localhost ~]$ cat /etc/nginx/nginx.conf
user web;
```

```bash
[tomfox@localhost ~]$ sudo systemctl restart nginx
[sudo] password for tomfox: 
[tomfox@localhost ~]$ ps -aux | grep nginx
web         5669  0.0  0.4 151820  7932 ?        S    13:03   0:00 nginx: worker process
```

**🌞 Changer l'emplacement de la racine Web**

```bash
[tomfox@localhost var]$ sudo mkdir www
[tomfox@localhost var]$ cd www/
[tomfox@localhost www]$ sudo mkdir super_site_web
[tomfox@localhost www]$ cd super_site_web/
[tomfox@localhost www]$ cd super_site_web/
[tomfox@localhost super_site_web]$ sudo vi index.html
[tomfox@localhost super_site_web]$ cd ..
[tomfox@localhost www]$ sudo chown -R web:web super_site_web/
[tomfox@localhost www]$ ls -la
total 4
drwxr-xr-x.  3 root root   28 Nov 23 13:11 .
drwxr-xr-x. 22 root root 4096 Nov 23 13:11 ..
drwxr-xr-x.  2 web  web    24 Nov 23 13:13 super_site_web
[tomfox@localhost www]$ ls -la super_site_web/
total 4
drwxr-xr-x. 2 web  web   24 Nov 23 13:13 .
drwxr-xr-x. 3 root root  28 Nov 23 13:11 ..
-rw-r--r--. 1 web  web  101 Nov 23 13:13 index.html
```

```bash
[tomfox@localhost www]$ cat /etc/nginx/nginx.conf | grep root
        root         /var/www/super_site_web;
[tomfox@localhost www]$ sudo systemctl restart nginx
```

```bash
❯ curl http://192.168.58.37:8080/
<!DOCTYPE html>
<html>
<body>

<h1>My First Heading</h1>
<p>My first paragraph.</p>

</body>
</html>
```
f
