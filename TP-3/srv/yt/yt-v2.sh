while :
do
	if [[ -d downloads && -d /var/log/yt ]]; then
		basepath=`pwd`
		for i in `cat links.txt | xargs`; do
			videoname=`youtube-dl -e $i 2>&1`
			if [[ $videoname =~ "ERROR" ]]; then
				echo "[`date "+%D %T"`] Error while downloading $i ($videoname)" >> /var/log/yt/downloads.log
				sed -i '1d' links.txt
			else
				sed -i '1d' links.txt
				mkdir "downloads/${videoname}"
				cd "downloads/${videoname}" && youtube-dl -f mp4 -o "${videoname}.mp4" $i &> /dev/null && youtube-dl --get-description $i > description
				echo "Video $i was downloaded."
				echo "File path : /srv/yt/downloads/${videoname}/${videoname}.mp4"
				echo "[`date "+%D %T"`] Video $i was downloaded. File path : /srv/yt/downloads/${videoname}/${videoname}.mp4" >> /var/log/yt/downloads.log
				cd $basepath
			fi
		done
	else
		echo "Il manque un dossier"
	fi
	sleep 5
done
