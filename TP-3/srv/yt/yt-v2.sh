path="/home/tomfox/tp-linux/TP-3/"
while :
do
        if [[ -d ${path}srv/yt/downloads && -d /var/log/yt ]]; then
                for i in $(cat ${path}srv/yt/links.txt | xargs); do
                        videoname=$(youtube-dl -e "$i" 2>&1)
                        if [[ ! $i =~ "https://www.youtube.com/watch" ]]; then
                                echo "[$(date "+%D %T")] Invalid link ($i)"
                                sed -i '1d' ${path}srv/yt/links.txt
                                continue
                        elif [[ $videoname =~ "ERROR" ]]; then
                                echo "[$(date "+%D %T")] Error while downloading $i ($videoname)" >> /var/log/yt/downloads.log
                                sed -i '1d' ${path}srv/yt/links.txt
                                continue
                        fi
                        sed -i '1d' ${path}srv/yt/links.txt
                        mkdir "/home/tomfox/tp-linux/TP-3/srv/yt/downloads/${videoname}"
                        cd "${path}srv/yt/downloads/${videoname}" && youtube-dl -f mp4 -o "${videoname}.mp4" "$i" &> /dev/null && youtube-dl --get-description "$i" > description
                        echo "Video $i was downloaded."
                        echo "File path : ${path}srv/yt/downloads/${videoname}/${videoname}.mp4"
                        echo "[$(date "+%D %T")] Video $i was downloaded. File path : ${path}srv/yt/downloads/${videoname}/${videoname}.mp4" >> /var/log/yt/downloads.log
                done
        else
                echo "Il manque un dossier"
        fi
        sleep 5
done
