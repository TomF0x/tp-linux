# TP 3 : A little script

## I. Script carte d'identité

📁 **Fichier [`/srv/idcard/idcard.sh`](https://github.com/TomF0x/tp-linux/blob/main/TP-3/srv/idcard/idcard.sh)**

🌞
```bash
tomfox@tomfox:~$ sudo bash idcard.sh 
Machine name : tomfox
OS Ubuntu 21.10 and kernel version is Linux 5.13.0-19-generic
IP: 10.0.2.15
RAM : 479Mi/1,9Gi
Disque : 2,8 Go left
Top 5 processes by RAM usage :
 - /usr/bin/python3
 - /usr/lib/xorg/Xorg
 - xfwm4
 - /usr/bin/python3
 - xfdesktop
Listening ports :
 - 53 : systemd-r
 - 631 : cupsd
 - 22 : sshd
Here's your random cat : https://cdn2.thecatapi.com/images/a14.jpg
```

<img src="https://cdn2.thecatapi.com/images/a14.jpg">

## II. Script youtube-dl

📁 **Le script [`/srv/yt/yt.sh`](https://github.com/TomF0x/tp-linux/blob/main/TP-3/srv/yt/yt.sh)**

📁 **Le fichier de log `/var/log/yt/download.log`**

```bash
❯ cat /var/log/yt/downloads.log
[11/19/21 10:40:59] Video https://www.youtube.com/watch?v=jjs27jXL0Zs was downloaded. File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE.mp4
[11/19/21 10:41:06] Video https://www.youtube.com/watch?v=Wch3gJG2GJ4 was downloaded. File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/1 Second Video/1 Second Video.mp4
[11/19/21 10:41:07] Error while downloading https://www.youtube.com/watch?v=Wch3gJfgdfhdhJ4 (ERROR: Video unavailable)
[11/19/21 10:41:24] Video https://www.youtube.com/watch?v=jNQXAC9IVRw was downloaded. File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/Me at the zoo/Me at the zoo.mp4
[11/19/21 10:49:00] Video https://www.youtube.com/watch?v=jjs27jXL0Zs was downloaded. File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE.mp4
[11/19/21 10:49:07] Video https://www.youtube.com/watch?v=Wch3gJG2GJ4 was downloaded. File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/1 Second Video/1 Second Video.mp4
[11/19/21 10:49:08] Error while downloading https://www.youtube.com/watch?v=Wch3gJfgdfhdhJ4 (ERROR: Video unavailable)
[11/19/21 10:49:25] Video https://www.youtube.com/watch?v=jNQXAC9IVRw was downloaded. File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/Me at the zoo/Me at the zoo.mp4
```

🌞
```
❯ sudo bash yt.sh https://www.youtube.com/watch\?v\=XD9lPNryAhM
Video https://www.youtube.com/watch?v=XD9lPNryAhM was downloaded.
File path : /srv/yt/downloads/One Piece New Opening Episode 1000/One Piece New Opening Episode 1000.mp4
```

```bash
❯ sudo bash yt.sh https://www.youtube.com/watch\?v\=sdzeefdg
ERROR: Incomplete YouTube ID sdzeefdg. URL https://www.youtube.com/watch?v=sdzeefdg looks truncated.
```

```bash
❯ sudo bash yt.sh https://www.youtube
Invalid link (https://www.youtube)
```

## III. MAKE IT A SERVICE

📁 **Le script [`/srv/yt/yt-v2.sh`](https://github.com/TomF0x/tp-linux/blob/main/TP-3/srv/yt/yt-v2.sh)**

📁 **Fichier `/etc/systemd/system/yt.service`**

```bash
❯ cat /etc/systemd/system/yt.service
[Unit]
Description=Youtube downloader

[Service]
ExecStart=sudo bash /home/tomfox/tp-linux/TP-3/srv/yt/yt-v2.sh

[Install]
WantedBy=multi-user.target
```

```bash
❯ systemctl status yt
● yt.service - Youtube downloader
     Loaded: loaded (/etc/systemd/system/yt.service; enabled; vendor preset: disabled)
     Active: active (running) since Fri 2021-11-19 23:11:16 CET; 2min 43s ago
   Main PID: 407 (sudo)
      Tasks: 3 (limit: 18800)
     Memory: 21.5M
        CPU: 5.528s
     CGroup: /system.slice/yt.service
             ├─ 407 sudo bash /home/tomfox/tp-linux/TP-3/srv/yt/yt-v2.sh
             ├─ 648 bash /home/tomfox/tp-linux/TP-3/srv/yt/yt-v2.sh
             └─2092 sleep 5

Nov 19 23:11:16 ZenBook systemd[1]: Started Youtube downloader.
Nov 19 23:11:17 ZenBook sudo[407]:     root : PWD=/ ; USER=root ; COMMAND=/usr/bin/bash /home/tomfox/tp-linux/TP-3/srv/yt/yt-v2.sh
Nov 19 23:11:17 ZenBook sudo[407]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=0)
Nov 19 23:13:49 ZeBook sudo[648]: Video https://www.youtube.com/watch?v=Wch3gJG2GJ4 was downloaded.
Nov 19 23:13:49 ZenBook sudo[648]: File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/1 Second Video/1 Second Video.mp4
```

```bash
❯ journalctl -xe -u yt
[...]
-- Boot 50037b85a2574849b16c71ff5aaf37ed --
Nov 19 23:11:16 ZenBook systemd[1]: Started Youtube downloader.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://forum.manjaro.org/c/support
░░ 
░░ A start job for unit yt.service has finished successfully.
░░ 
░░ The job identifier is 113.
Nov 19 23:11:17 ZenBook sudo[407]:     root : PWD=/ ; USER=root ; COMMAND=/usr/bin/bash /home/tomfox/tp-linux/TP-3/srv/yt/yt-v2.sh
Nov 19 23:11:17 ZenBook sudo[407]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=0)
Nov 19 23:13:49 ZenBook sudo[648]: Video https://www.youtube.com/watch?v=Wch3gJG2GJ4 was downloaded.
Nov 19 23:13:49 ZenBook sudo[648]: File path : /home/tomfox/tp-linux/TP-3/srv/yt/downloads/1 Second Video/1 Second Video.mp4
```

```bash
sudo systemctl enable yt
```

🌟**BONUS** :

[![asciicast](https://asciinema.org/a/zAjOwISrOxtWDaCxRFApCgwDf.svg)](https://asciinema.org/a/zAjOwISrOxtWDaCxRFApCgwDf)

## IV. Bonus
