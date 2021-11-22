#!/usr/bin/env bash

usage() {
	echo "Usage: yt.sh [options...] <url>"
	echo " -q <quality> (best,worst,bestvideo,worstvideo,bestaudio,worstaudio)"
	echo " -o <directory> output file"
	echo " -h to show this menu"
	exit
}

if [[ $1 == "-h" || $(($# % 2)) == 0 ]]; then 
	usage
fi
if ! command -v youtube-dl &> /dev/null; then
        echo "You need to install youtube-dl (https://github.com/ytdl-org/youtube-dl)"
        exit
fi
if [[ -d downloads && -d /var/log/yt ]]; then
        videoname=$(youtube-dl -e "${!#}" 2>&1)
        if [[ ! ${!#} =~ https://www.youtube.com/watch ]]; then
                echo "Invalid link (${!#})"
                echo "[$(date "+%D %T")] Invalid link (${!#})" >> /var/log/yt/downloads.log
        elif [[ $videoname =~ "ERROR" ]]; then
                echo "$videoname"
                exit
        else
		downloadpath="downloads/"
		if [[ $1 == "-o" ]]; then
			downloadpath=$2
		fi
		mkdir "${downloadpath}${videoname}"
                if [[ $1 == "-q" ]]; then 
			cd "${downloadpath}${videoname}" && youtube-dl -f "$2/mp4" -o "${videoname}.mp4" "${!#}" &> /dev/null && youtube-dl --get-description "${!#}" > description
		else
			cd "${downloadpath}${videoname}" && youtube-dl -f mp4 -o "${videoname}.mp4" "${!#}" &> /dev/null && youtube-dl --get-description "${!#}" > description
		fi
		echo "Video ${!#} was downloaded."
                echo "File path : ${downloadpath}${videoname}/${videoname}.mp4"
                echo "[$(date "+%D %T")] Video ${!#} was downloaded. File path : ${downloadpath=}${videoname}/${videoname}.mp4" >> /var/log/yt/downloads.log
                exit
        fi
else
        echo "Il manque un dossier"
        exit
fi
