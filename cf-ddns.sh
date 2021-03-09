#!/bin/bash

### Important! ###
# If you upload your own changes to this script, be absolutely certain not to include your actual API token.
### Important! ###

working_dir="/home/youruser/cf-ddns/"
domain="ddns.example.com"
get_pub_ip_url="http://ipinfo.io/ip"
cf_api_url="the-url-goes-here"
cf_api_token="the-token-goes-here"
proxied="true"

cd $working_dir

#Get the local network's public IP.
/usr/bin/curl --silent --show-error $get_pub_ip_url > public-ip.tmp 2>> cf-ddns-error-log
public_ip=$(/bin/cat public-ip.tmp)

if ! [[ $public_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    /bin/echo $(date +%F\ %T)" Value retrieved for the public IP was not a valid IP address, exiting. Is "$get_pub_ip_url" reachable?" >> cf-ddns-error-log
    exit
fi

#Compare the current public IP with the previous one, and update the A record at CloudFlare if they differ.
if [ "$public_ip" != "$(/bin/cat public-ip)" ]; then
    /usr/bin/curl --silent --show-error -X PUT $cf_api_url \
        -H "Authorization: Bearer $cf_api_token" \
        -H "Content-Type:application/json" \
        --data '{"type":"A","name":"'$domain'","content":"'$public_ip'","ttl":1,"proxied":'$proxied'}' > cf-api-result.tmp 2>> cf-ddns-error-log

    if ! [ `/bin/grep '"success":true' cf-api-result.tmp`  ]; then
        /bin/echo $(date +%F\ %T)" Updating A record at CloudFlare failed, exiting. API response is the following line." >> cf-ddns-error-log
        /bin/echo $(/bin/cat cf-api-result.tmp) >> cf-ddns-error-log
        exit
    else
        #Update the file for next time.
        /bin/mv -f public-ip.tmp public-ip
    fi
fi
