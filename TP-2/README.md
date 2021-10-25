# TP2 : Explorer et manipuler le système

---

**🌞 Changer le nom de la machine**

```bash
tomfox@tomfox: sudo hostname node1.tp2.linux
tomfox@tomfox:~$ hostname
node1.tp2.linux
tomfox@tomfox: echo "node1.tp2.linux" | sudo tee /etc/hostname
node1.tp2.linux
```

**🌞 Config réseau fonctionnelle**

Coté VM:
```bash
tomfox@node1:~$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=63 time=22.8 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=63 time=24.0 ms
--- 1.1.1.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 22.789/23.418/24.047/0.629 ms
tomfox@node1:~$ ping ynov.com
PING ynov.com (92.243.16.143) 56(84) bytes of data.
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=1 ttl=63 time=20.6 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=2 ttl=63 time=21.1 ms
--- ynov.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 20.592/20.870/21.148/0.278 ms
```

Coté PC:
```bash
❯ ping 192.168.56.112
PING 192.168.56.112 (192.168.56.112) 56(84) bytes of data.
64 bytes from 192.168.56.112: icmp_seq=1 ttl=64 time=0.550 ms
64 bytes from 192.168.56.112: icmp_seq=2 ttl=64 time=0.558 ms
--- 192.168.56.112 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1023ms
rtt min/avg/max/mdev = 0.550/0.554/0.558/0.004 ms

```

## Partie 1 : SSH

**🌞 Installer le paquet openssh-server**

```bash
tomfox@node1:~$ sudo apt install openssh-server -y
tomfox@node1:~$ systemctl start sshd
tomfox@node1:~$ systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 11:27:01 CEST; 44s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 546 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 574 (sshd)
      Tasks: 1 (limit: 2314)
     Memory: 2.3M
        CPU: 12ms
     CGroup: /system.slice/ssh.service
             └─574 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
[...]
```

**🌞 Analyser le service en cours de fonctionnement**

```bash
tomfox@node1:~$ systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 11:27:01 CEST; 44s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 546 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 574 (sshd)
      Tasks: 1 (limit: 2314)
     Memory: 2.3M
        CPU: 12ms
     CGroup: /system.slice/ssh.service
             └─574 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
[...]
tomfox@node1:~$ ps -aux | grep sshd
root         574  0.0  0.3  13132  6832 ?        Ss   11:27   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
tomfox@node1:~$ ss -l | grep ssh
u_str LISTEN 0      4096         /run/user/1000/gnupg/S.gpg-agent.ssh 19091                           * 0           
u_str LISTEN 0      10                     /run/user/1000/keyring/ssh 19713                           * 0           
tcp   LISTEN 0      128                                       0.0.0.0:ssh                       0.0.0.0:*           
tcp   LISTEN 0      128                                          [::]:ssh                          [::]:*
tomfox@node1:~$ journalctl | grep sshd
[...]
```

**🌞 Connectez vous au serveur**

```bash
❯ ssh tomfox@192.168.56.112
tomfox@192.168.56.112 s password: 
Welcome to Ubuntu 21.10 (GNU/Linux 5.13.0-19-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

1 update can be applied immediately.
1 of these updates is a standard security update.
To see these additional updates run: apt list --upgradable


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

tomfox@node1:~$ 
```

**🌞 Modifier le comportement du service**

```bash
tomfox@node1:/etc/ssh$ sudo nano /etc/ssh/sshd_config
tomfox@node1:/etc/ssh$ cat /etc/ssh/sshd_config
#       $OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf

Port 2222
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
tomfox@node1:/etc/ssh$ systemctl restart sshd 
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to restart 'ssh.service'.
Authenticating as: tomfox,,, (tomfox)
Password: 
==== AUTHENTICATION COMPLETE ===
tomfox@node1:~$ ss -l | grep 2222
tcp   LISTEN 0      128                                       0.0.0.0:2222                      0.0.0.0:*           
tcp   LISTEN 0      128                                          [::]:2222                         [::]:*
❯ ssh tomfox@192.168.56.112 -p 2222
tomfox@192.168.56.112 s password: 
Welcome to Ubuntu 21.10 (GNU/Linux 5.13.0-19-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

0 updates can be applied immediately.

Last login: Mon Oct 25 11:53:19 2021 from 192.168.56.1
tomfox@node1:~$
```

---

## Partie 2 : FTP

**🌞 Installer le paquet vsftpd**

```bash
tomfox@node1:~$ sudo apt install vsftpd -y
[...]
```

**🌞 Lancer le service vsftpd**

```bash
tomfox@node1:~$ systemctl start vsftpd
[...]
tomfox@node1:~$ systemctl status vsftpd
● vsftpd.service - vsftpd FTP server
     Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 12:07:23 CEST; 1min 22s ago
    Process: 1738 ExecStartPre=/bin/mkdir -p /var/run/vsftpd/empty (code=exited, status=0/SUCCESS)
   Main PID: 1739 (vsftpd)
      Tasks: 1 (limit: 2314)
     Memory: 684.0K
        CPU: 2ms
     CGroup: /system.slice/vsftpd.service
             └─1739 /usr/sbin/vsftpd /etc/vsftpd.conf
[...]
```

**🌞 Analyser le service en cours de fonctionnement**

```bash
tomfox@node1:~$ systemctl status vsftpd
● vsftpd.service - vsftpd FTP server
     Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 12:07:23 CEST; 1min 22s ago
    Process: 1738 ExecStartPre=/bin/mkdir -p /var/run/vsftpd/empty (code=exited, status=0/SUCCESS)
   Main PID: 1739 (vsftpd)
      Tasks: 1 (limit: 2314)
     Memory: 684.0K
        CPU: 2ms
     CGroup: /system.slice/vsftpd.service
             └─1739 /usr/sbin/vsftpd /etc/vsftpd.conf
[...]
tomfox@node1:~$ ps -aux | grep ftp
root        1739  0.0  0.1   8668  3756 ?        Ss   12:07   0:00 /usr/sbin/vsftpd /etc/vsftpd.conf
tomfox@node1:~$ ss -l | grep ftp
tcp   LISTEN 0      32                                              *:ftp                             *:*
tomfox@node1:~$ journalctl | grep vsftpd
oct. 25 12:06:58 node1.tp2.linux polkitd(authority=local)[460]: Operator of unix-process:1573:51411 successfully authenticated as unix-user:tomfox to gain ONE-SHOT authorization for action org.freedesktop.systemd1.manage-units for system-bus-name::1.80 [systemctl start vsftpd] (owned by unix-user:tomfox)
oct. 25 12:07:22 node1.tp2.linux sudo[1586]:   tomfox : TTY=pts/0 ; PWD=/home/tomfox ; USER=root ; COMMAND=/usr/bin/apt install vsftpd
oct. 25 12:07:23 node1.tp2.linux systemd[1]: Starting vsftpd FTP server...
oct. 25 12:07:23 node1.tp2.linux systemd[1]: Started vsftpd FTP server.
oct. 25 12:08:42 node1.tp2.linux polkitd(authority=local)[460]: Operator of unix-process:2243:61682 successfully authenticated as unix-user:tomfox to gain ONE-SHOT authorization for action org.freedesktop.systemd1.manage-units for system-bus-name::1.90 [systemctl start vsftpd] (owned by unix-user:tomfox)
oct. 25 12:15:59 node1.tp2.linux sudo[2264]:   tomfox : TTY=pts/0 ; PWD=/home/tomfox ; USER=root ; COMMAND=/usr/bin/apt install vsftpd -y
tomfox@node1:~$ sudo cat /var/log/vsftpd.log 
Mon Oct 25 12:33:07 2021 [pid 2458] CONNECT: Client "::ffff:192.168.56.1"
Mon Oct 25 12:33:25 2021 [pid 2457] [Anonymous] FAIL LOGIN: Client "::ffff:192.168.56.1"
Mon Oct 25 12:33:33 2021 [pid 2466] CONNECT: Client "::ffff:192.168.56.1"
Mon Oct 25 12:33:41 2021 [pid 2465] [tomfox] OK LOGIN: Client "::ffff:192.168.56.1"
```

```bash
tomfox@node1:~$ sudo cat /etc/vsftpd.conf 
# Uncomment this to enable any form of FTP write command.
write_enable=YES
tomfox@node1:~$ systemctl restart vsftpd
❯ ftp 192.168.56.112
Connected to 192.168.56.112.
220 (vsFTPd 3.0.3)
Name (192.168.56.112:tomfox): tomfox
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> dir
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:33 Desktop
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:33 Documents
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:33 Downloads
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:33 Music
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:33 Pictures
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:33 Public
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:34 Templates
drwxr-xr-x    2 1000     1000         4096 Oct 19 11:33 Videos
-rw-rw-r--    1 1000     1000            5 Oct 25 12:46 test.txt
226 Directory send OK.
ftp> get
(remote-file) test.txt
(local-file) test.txt
200 PORT command successful. Consider using PASV.
150 Opening BINARY mode data connection for test.txt (5 bytes).
226 Transfer complete.
5 bytes received in 0.000105 seconds (46.5 kbytes/s)
```
On peut aussi utiliser FileZilla

**🌞 Visualiser les logs**

```bash
tomfox@node1:~$ sudo cat /var/log/vsftpd.log 
Mon Oct 25 12:45:37 2021 [pid 2570] CONNECT: Client "::ffff:192.168.56.1"
Mon Oct 25 12:45:43 2021 [pid 2569] [tomfox] OK LOGIN: Client "::ffff:192.168.56.1"
Mon Oct 25 12:46:46 2021 [pid 2571] [tomfox] OK DOWNLOAD: Client "::ffff:192.168.56.1", "/home/tomfox/test.txt", 5 bytes, 3.54Kbyte/sec
Mon Oct 25 12:57:09 2021 [pid 2677] CONNECT: Client "::ffff:192.168.56.1"
Mon Oct 25 12:57:13 2021 [pid 2676] [tomfox] OK LOGIN: Client "::ffff:192.168.56.1"
Mon Oct 25 12:57:45 2021 [pid 2680] CONNECT: Client "::ffff:192.168.56.1"
Mon Oct 25 12:57:45 2021 [pid 2679] [tomfox] OK LOGIN: Client "::ffff:192.168.56.1"
Mon Oct 25 12:57:45 2021 [pid 2681] [tomfox] OK UPLOAD: Client "::ffff:192.168.56.1", "/home/tomfox/img.png", 4696 bytes, 1497.20Kbyte/sec
```

**🌞 Modifier le comportement du service**

```bash
tomfox@node1:~$ sudo cat /etc/vsftpd.conf 
[...]
listen_port=12345
[...]
tomfox@node1:~$ ss -l | grep 12345
tcp   LISTEN 0      32                                              *:12345                           *:*
```

**🌞 Connectez vous sur le nouveau port choisi**

```bash
❯ ftp 192.168.56.112 -p 12345
Connected to 192.168.56.112.
220 (vsFTPd 3.0.3)
Name (192.168.56.112:tomfox): tomfox
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
tomfox@node1:~$ sudo cat /var/log/vsftpd.log 
Mon Oct 25 14:00:29 2021 [pid 3067] CONNECT: Client "::ffff:192.168.56.1"
Mon Oct 25 14:00:29 2021 [pid 3066] [tomfox] OK LOGIN: Client "::ffff:192.168.56.1"
Mon Oct 25 14:00:29 2021 [pid 3068] [tomfox] OK UPLOAD: Client "::ffff:192.168.56.1", "/home/tomfox/Public/img.png", 4696 bytes, 13488.05Kbyte/sec
Mon Oct 25 14:00:37 2021 [pid 3070] CONNECT: Client "::ffff:192.168.56.1"
Mon Oct 25 14:00:37 2021 [pid 3069] [tomfox] OK LOGIN: Client "::ffff:192.168.56.1"
Mon Oct 25 14:00:37 2021 [pid 3071] [tomfox] OK DOWNLOAD: Client "::ffff:192.168.56.1", "/home/tomfox/Templates/Plain Text.txt", 0.00Kbyte/sec
```

## Partie 3 : Création de votre propre service

```bash
tomfox@node1:~$ nc -l 9001
❯ nc 192.168.56.112 9001
```

**🌞 Utiliser netcat pour stocker les données échangées dans un fichier**

```bash
tomfox@node1:~$ nc -l 9001 >> log.txt
```

**🌞 Créer un nouveau service**

```bash
tomfox@node1:~$ sudo nano /etc/systemd/system/chat_tp2.service
tomfox@node1:~$ sudo cat /etc/systemd/system/chat_tp2.service 
[Unit]
Description=Little chat service (TP2)

[Service]
ExecStart=/usr/bin/nc -l 9002

[Install]
WantedBy=multi-user.target
```

**🌞 Tester le nouveau service**

```bash
tomfox@node1:~$ systemctl start chat_tp2
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'chat_tp2.service'.
Authenticating as: tomfox,,, (tomfox)
Password: 
==== AUTHENTICATION COMPLETE ===
tomfox@node1:~$ systemctl status chat_tp2
● chat_tp2.service - Little chat service (TP2)
     Loaded: loaded (/etc/systemd/system/chat_tp2.service; disabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 14:19:43 CEST; 3min 29s ago
   Main PID: 3476 (nc)
      Tasks: 1 (limit: 2314)
     Memory: 216.0K
        CPU: 2ms
     CGroup: /system.slice/chat_tp2.service
             └─3476 /usr/bin/nc -l 9002

oct. 25 14:19:43 node1.tp2.linux systemd[1]: Started Little chat service (TP2).
tomfox@node1:~$ ss -l | grep 9002
tcp   LISTEN 0      1                                         0.0.0.0:9002                      0.0.0.0:*
tomfox@node1:~$ journalctl -xe -u chat_tp2
oct. 25 14:24:50 node1.tp2.linux nc[3476]: salut
oct. 25 14:24:51 node1.tp2.linux nc[3476]: test
```