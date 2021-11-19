if [[ -d downloads && -d /var/log/yt ]];
        then
        videoname=$(youtube-dl -e "$1" 2>&1)
        if [[ ! $1 =~ "https://www.youtube.com/watch" ]]; then
                echo "[$(date "+%D %T")] Invalid link ($1)"
                sed -i '1d' links.txt
        elif [[ $videoname =~ "ERROR" ]]; then
                echo "$videoname"
                exit
        else
                mkdir "downloads/${videoname}"
                cd "downloads/${videoname}" && youtube-dl -f mp4 -o "${videoname}.mp4" "$1" &> /dev/null && youtube-dl --get-description "$1" > description
                echo "Video $1 was downloaded."
                echo "File path : /srv/yt/downloads/${videoname}/${videoname}.mp4"
                echo "[$(date "+%D %T")] Video $1 was downloaded. File path : /srv/yt/downloads/${videoname}/${videoname}.mp4" >> /var/log/yt/downloads.log
                exit
        fi
else
        echo "Il manque un dossier"
        exit
fi
