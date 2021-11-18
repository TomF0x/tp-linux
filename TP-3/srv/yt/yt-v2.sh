if [[ -d downloads && -d /var/log/yt ]]; then
	basepath=`pwd`
	for i in `cat links.txt | xargs`; do
        	videoname=`youtube-dl -e $i`
        	mkdir "downloads/${videoname}"
		sed -i '1d' links.txt
        	cd "downloads/${videoname}" && youtube-dl -f mp4 -o "${videoname}.mp4" $i &> /dev/null && youtube-dl --get-description $i > description
        	echo "Video $i was downloaded."
        	echo "File path : /srv/yt/downloads/${videoname}/${videoname}.mp4"
		echo "[`date "+%D %T"`] Video $i was downloaded. File path : /srv/yt/downloads/${videoname}/${videoname}.mp4" >> /var/log/yt/downloads.log
		cd $basepath
	done
	exit
else
        echo "Il manque un dossier"
        exit
fi
