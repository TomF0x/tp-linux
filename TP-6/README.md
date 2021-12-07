# TP6 : Stockage et sauvegarde

## Partie 1 : Préparation de la machine `backup.tp6.linux`

### I. Ajout de disque

**🌞 Ajouter un disque dur de 5Go à la VM `backup.tp6.linux`**

```bash
[tomfox@backup ~]$ lsblk | grep sdb
sdb           8:16   0    5G  0 disk
```

### II. Partitioning

**🌞 Partitionner le disque à l'aide de LVM**

```bash
[tomfox@backup ~]$ sudo pvcreate /dev/sdb
[sudo] password for tomfox: 
  Physical volume "/dev/sdb" successfully created.
[tomfox@backup ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0 
  /dev/sdb      lvm2 ---   5.00g 5.00g
[tomfox@backup ~]$ sudo pvdisplay  
[...]
  "/dev/sdb" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name               
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               MVjIIR-pWYt-hx9c-qCNf-7Jav-ossn-xYHZtK
[tomfox@backup ~]$ sudo vgcreate backup /dev/sdb
  Volume group "backup" successfully created
[tomfox@backup ~]$ sudo lvcreate -l 100%FREE backup -n lv_backup
  Logical volume "lv_backup" created.
[tomfox@backup ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/backup/lv_backup
  LV Name                lv_backup
  VG Name                backup
  LV UUID                Sd3fhf-B7if-2iKk-dfRs-CGDS-9Aa1-B4p61T
  LV Write Access        read/write
  LV Creation host, time backup.tp6.linux, 2021-11-30 11:17:04 +0100
  LV Status              available
  # open                 0
  LV Size                <5.00 GiB
  Current LE             1279
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
```

**🌞 Formater la partition**

```bash
[tomfox@backup ~]$ sudo mkfs -t ext4 /dev/backup/lv_backup
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 1309696 4k blocks and 327680 inodes
Filesystem UUID: 71423fc2-8249-457b-ba84-64560341c062
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 
```

**🌞 Monter la partition**

```bash
[tomfox@backup ~]$ sudo mkdir /backup
[tomfox@backup ~]$ sudo mount /dev/backup/lv_backup /backup
[tomfox@backup ~]$ df -h | grep backup
/dev/mapper/backup-lv_backup  4.9G   20M  4.6G   1% /backup
[tomfox@backup ~]$ sudo chown tomfox:tomfox /backup
[tomfox@backup ~]$ echo "test" > /backup/test.txt
[tomfox@backup ~]$ cat /backup/test.txt
test 
[tomfox@backup ~]$ rm /backup/test.txt
[tomfox@backup ~]$ cat /etc/fstab | grep backup
/dev/backup/lv_backup /backup ext4 defaults 0 0
[tomfox@backup ~]$ sudo umount /backup 
[tomfox@backup ~]$ sudo mount -av
[...]
/backup                  : successfully mounted
```


## Partie 2 : Setup du serveur NFS sur backup.tp6.linux

**🌞 Préparer les dossiers à partager**

```bash
[tomfox@backup ~]$ mkdir /backup/web.tp6.linux
[tomfox@backup ~]$ mkdir /backup/db.tp6.linux
```

**🌞 Install du serveur NFS**

```bash
[tomfox@backup ~]$ sudo dnf install nfs-utils
[...]
Complete!
```

**🌞 Conf du serveur NFS**

```bash
[tomfox@backup ~]$ cat /etc/idmapd.conf | grep Domain
Domain = tp6.linux
[tomfox@backup ~]$ cat /etc/exports
/backup/web.tp6.linux 10.5.1.11(rw,no_root_squash)
/backup/db.tp6.linux 10.5.1.12(rw,no_root_squash)
```
La perm rw donne la permission de lire et écrire dans /backup/web.tp6.linux ou /backup/db.tp6.linux (suivant la ligne), il donne cette permission uniquement a ip ou domaine qui est sur la même ligne.
La perm no_root_squash désactive la transformation de l'administrateur.

**🌞 Démarrez le service**

```bash
[tomfox@backup ~]$ sudo systemctl start nfs-server
[tomfox@backup ~]$ systemctl status nfs-server
● nfs-server.service - NFS server and srvices
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
   Active: active (exited) since Tue 2021-11-30 12:36:35 CET; 8s ago
  Process: 25333 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 25321 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
  Process: 25320 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 25333 (code=exited, status=0/SUCCESS)

Nov 30 12:36:35 backup.tp6.linux systemd[1]: Starting NFS server and services...
Nov 30 12:36:35 backup.tp6.linux systemd[1]: Started NFS server and services.
[tomfox@backup ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
```

**🌞 Firewall**

```bash
[tomfox@backup ~]$ sudo firewall-cmd --add-port=2049/tcp --permanent
success
[tomfox@backup ~]$ sudo firewall-cmd --reload
success
[tomfox@backup ~]$ sudo systemctl restart nfs-server
[tomfox@backup ~]$ sudo ss -laputen | grep 2049
udp   UNCONN 0      0               0.0.0.0:58519      0.0.0.0:*     ino:62049 sk:18 <->                                                                                
tcp   LISTEN 0      64              0.0.0.0:2049       0.0.0.0:*     ino:62035 sk:1c <->                                                                                
tcp   LISTEN 0      64                 [::]:2049          [::]:*     ino:62048 sk:20 v6only:1 <-
```

## Partie 3 : Setup des clients NFS : `web.tp6.linux` et `db.tp6.linux`


**🌞 Install'**

```bash
[tomfox@web1 ~]$ sudo dnf install nfs-utils
[...]
Complete!
```

**🌞 Conf'**

```bash
[tomfox@web1 ~]$ sudo mkdir /srv/backup
[tomfox@web1 ~]$ cat /etc/idmapd.conf | grep tp6.linux
Domain = tp6.linux
[tomfox@web1 ~]$ sudo mount -t nfs 10.5.1.13:/backup/web.tp6.linux /srv/backup
```

**🌞 Montage !**

```bash
[tomfox@web1 ~]$ df -h | grep backup
10.5.1.13:/backup/web.tp6.linux  4.9G   20M  4.6G   1% /srv/backup
[tomfox@web1 ~]$ echo "testmec" > /srv/backup/test.txt
[tomfox@web1 ~]$ cat /srv/backup/test.txt 
testmec
[tomfox@web1 ~]$ cat /etc/fstab | grep backup
10.5.1.13:/backup/web.tp6.linux /srv/backup nfs defaults 0 0
[tomfox@web1 ~]$ sudo umount /srv/backup
[tomfox@web1 ~]$ sudo mount -av
[...]
mount.nfs: timeout set for Tue Nov 30 13:20:16 2021
mount.nfs: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.11'
/srv/backup              : successfully mounted
```

**🌞 Répétez les opérations sur `db.tp6.linux`**

```bash
[tomfox@db ~]$ df -h | grep backup
10.5.1.13:/backup/db.tp6.linux  4.9G   20M  4.6G   1% /srv/backup
[tomfox@db ~]$ echo "lepetittest" > /srv/backup/testmec.txt
[tomfox@db ~]$ cat /srv/backup/testmec.txt
lepetittest
[tomfox@db ~]$ cat /etc/fstab | grep db
10.5.1.13:/backup/db.tp6.linux /srv/backup nfs defaults 0 0
[tomfox@db ~]$ sudo umount /srv/backup 
[tomfox@db ~]$ sudo mount -av
[...]
mount.nfs: timeout set for Tue Nov 30 13:31:10 2021
mount.nfs: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.12'
/srv/backup              : successfully mounted
```

## Partie 4 : Scripts de sauvegarde

### I. Sauvegarde Web

**🌞 Ecrire un script qui sauvegarde les données de NextCloud**

```bash
#!/bin/bash
filename="nextcloud_$(date +"%y%m%d")_$(date +"%H%M%S").tar.gz"
cd /var/www && tar -czf "/srv/backup/${filename}" nextcloud
echo "Backup /srv/backup/${filename} created successfully."
echo "[$(date +"%y:%m:%d") $(date +"%H:%M:%S")] Backup /srv/backup/${filename} created successfully." >> /var/log/backup/backup.log
```

**🌞 Créer un service**

```bash
[tomfox@web1 ~]$ cat /etc/systemd/system/backup.service
[Unit]
Description=Auto Backup

[Service]
ExecStart=/usr/bin/bash /home/tomfox/backupscript.sh
Type=oneshot

[Install]
WantedBy=multi-user.target
```

```bash
[tomfox@web1 ~]$ sudo systemctl start backup
[sudo] password for tomfox: 
[tomfox@web1 ~]$ sudo systemctl status backup
● backup.service - Auto Backup
   Loaded: loaded (/etc/systemd/system/backup.service; disabled; vendor preset: disabled)
   Active: inactive (dead)

Dec 07 17:04:34 web1.tp5.linux systemd[1]: Starting Auto Backup...
Dec 07 17:04:56 web1.tp5.linux bash[2005]: Backup /srv/backup/nextcloud_211207_170434.tar.gz created successfully.
Dec 07 17:04:56 web1.tp5.linux systemd[1]: backup.service: Succeeded.
Dec 07 17:04:56 web1.tp5.linux systemd[1]: Started Auto Backup.
```

**🌞 Vérifier que vous êtes capables de restaurer les données**

```bash
[tomfox@web1 ~]$ cp /srv/backup/nextcloud_211207_165742.tar.gz /home/tomfox
[tomfox@web1 ~]$ ls
backupscript.sh  nextcloud_211207_165742.tar.gz
[tomfox@web1 ~]$ tar -xf nextcloud_211207_165742.tar.gz 
[tomfox@web1 ~]$ ls
[tomfox@web1 ~]$ sudo -g apache mv nextcloud /var/www/
mv: replace '/var/www/nextcloud', overriding mode 0755 (rwxr-xr-x)? 
```

**🌞 Créer un timer**

```bash
[tomfox@web1 ~]$ sudo vi /etc/systemd/system/backup.timer
[sudo] password for tomfox: 
[tomfox@db ~]$ cat /etc/systemd/system/backup.timer
[Unit]
Description=Lance backup.service à intervalles réguliers
Requires=backup.service

[Timer]
Unit=backup.service
OnCalendar=hourly

[Install]
WantedBy=timers.target
[tomfox@web1 ~]$ sudo systemctl daemon-reload
[tomfox@web1 ~]$ sudo systemctl start backup.timer
[tomfox@web1 ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[tomfox@web1 ~]$ sudo systemctl list-timers | grep backup.timer
Tue 2021-12-07 18:00:00 CET  21min left n/a                          n/a       backup.timer                 backup.service
```

### II. Sauvegarde base de données

**🌞 Ecrire un script qui sauvegarde les données de la base de données MariaDB**

```bash
#!/bin/bash
filename="nextcloud_db_$(date +"%y%m%d")_$(date +"%H%M%S").tar.gz"
mysqldump -u root -pTom03042003 nextcloud > /home/tomfox/nextcloud.sql
cd /home/tomfox && tar -czf "/srv/backup/${filename}" nextcloud.sql
rm nextcloud.sql
echo "Backup /srv/backup/${filename} created successfully."
echo "[$(date +"%y:%m:%d") $(date +"%H:%M:%S")] Backup /srv/backup/${filename} created successfully." >> /var/log/backup/backup.log
```

**🌞 Créer un service**

```bash
[tomfox@db ~]$ cat /etc/systemd/system/backup_db.service
[Unit]
Description=Auto Backup

[Service]
ExecStart=/usr/bin/bash /home/tomfox/backupscript.sh
Type=oneshot

[Install]
WantedBy=multi-user.target
[tomfox@db ~]$ sudo systemctl start backup_db
[tomfox@db ~]$ ls -la /srv/backup/
total 68
drwxrwxr-x. 2 tomfox tomfox  4096 Dec  7 18:19 .
drwxr-xr-x. 3 root   root      20 Nov 30 13:23 ..
-rw-r--r--. 1 root   root   65296 Dec  7 18:19 nextcloud_db_211207_181926.tar.gz
```

**🌞 Créer un `timer`**

```bash
[tomfox@db ~]$ cat /etc/systemd/system/backup_db.timer
[Unit]
Description=Lance backup.service à intervalles réguliers
Requires=backup_db.service

[Timer]
Unit=backup_db.service
OnCalendar=hourly

[Install]
WantedBy=timers.target
[tomfox@db ~]$ sudo systemctl daemon-reload
[tomfox@db ~]$ sudo systemctl start backup.timer
[tomfox@db ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup_db.timer → /etc/systemd/system/backup_db.timer.
[tomfox@db ~]$ sudo systemctl list-timers | grep backup
Tue 2021-12-07 19:00:00 CET  32min left    n/a                          n/a          backup_db.timer                 backup_db.service
```
