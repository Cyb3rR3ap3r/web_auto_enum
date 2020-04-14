#!/bin/bash


### This script utilizes the following tools in order to work correctly
# assetfinder
# amass
# httprobe
# gowitness

### May add in future
# waybackurls
# subjack
# nmap  (open ports, ssl info)


url=$1    # This is setting the first argument as variable

if [ "$1" == "" ];then                 # Error handling for no domain
  echo "You forgot to enter domain.."
  echo "Syntax:  ./run.sh example.com"
  exit
fi


if [ ! -d "$url" ];then      # This is saying if $url directory doesn't
  mkdir $url                 # exist then create it.
fi

if [ ! -d "$url/recon" ];then
  mkdir $url/recon
fi

if [ ! -d "$url/recon" ];then
  mkdir $url/recon
fi

if [ ! -d "$url/recon/assetfinder" ];then
  mkdir $url/recon/assetfinder
fi

if [ ! -d "$url/recon/amass" ];then
  mkdir $url/recon/amass
fi

if [ ! -d "$url/recon/httprobe" ];then
  mkdir $url/recon/httprobe
fi

if [ ! -d "$url/recon/gowitness" ];then
  mkdir $url/recon/gowitness
fi

########################################################################


echo "[+] Harvesting subdomains with assetfinder..."
assetfinder $url >> $url/recon/assets.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/assetfinder.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/assetfinder/assets.txt
rm $url/recon/assets.txt

echo "[+] Harvesting subdomains with amass..."
amass enum -d $url >> $url/recon/amass.txt
cat $url/recon/amass.txt >> $url/recon/amass/assets.txt
cat $url/recon/assetfinder.txt $url/recon/amass.txt >> $url/recon/almost.txt
sort -u $url/recon/almost.txt >> $url/recon/subdomains.txt
rm $url/recon/assetfinder.txt
rm $url/recon/amass.txt
rm $url/recon/almost.txt

echo "[+] Testing status of subdomains..."
cat $url/recon/subdomains.txt | sort -u | httprobe >> $url/recon/a.txt
cat $url/recon/a.txt >> $url/recon/httprobe/assets.txt
cat $url/recon/a.txt | sed 's/https\?:\/\///' >> $url/recon/al.txt
sort -u $url/recon/al.txt >> $url/recon/alive_subdomains.txt
rm $url/recon/a.txt
rm $url/recon/al.txt

echo "[+] Capturing screenshots of active webpages..."
gowitness file -s $url/recon/httprobe/assets.txt -d $url/recon/gowitness
rm ./gowitness.db
