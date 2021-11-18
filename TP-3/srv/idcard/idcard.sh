os=`hostnamectl | grep System`
kv=`hostnamectl | grep Kernel`
echo "Machine name : `uname -n`"
echo "OS ${os:18} and kernel version is ${kv:18}"
echo "IP: `hostname -I | awk '{print $1}'`"
echo "RAM : `free -h | grep Mem | awk '{print $3}'`/`free -h | grep Mem | awk '{print $2}'`"
echo "Disque : `df -h / | grep dev | awk '{print $4}' | tr -d 'G'` Go left"
echo "Top 5 processes by RAM usage :"
echo "`ps -aux --sort -%mem | head -n 6 | tail -n 5 | awk '{print " - " $11}'`"
echo "Listening ports :"
echo "`lsof -i -P | grep LISTEN | uniq -w 20 | awk '{print "- " $9 " : " $1}' | tr ":" " " | awk '{print " - " $3 " : " $4}'`"
echo "Here's your random cat : `curl -s https://api.thecatapi.com/v1/images/search | jq -r ".[].url"`"
