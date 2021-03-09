# DDNS-Using-CloudFlare
This script will get the public IP address of the machine that it is ran from, compare that IP to the value of an A record at CloudFlare, and update the A record if the public IP has changed.

This guide assumes that you have the following:
- A Linux machine on your local network
- A domain name that you control DNS for (get one [for free from GitHub](https://education.github.com/pack) for a year if you're a student)
- [A CloudFlare account](https://support.cloudflare.com/hc/en-us/articles/201720164-Creating-a-Cloudflare-account-and-adding-a-website)

This script depends on:
- The site that you use to see your public IP being available
- api.cloudflare.com being available

Once your domain is added to CloudFlare, you'll need to create [API tokens](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys).
This token that you'll use for this script just needs read access.
![Image of Token Permissions at CloudFlare](https://github.com/ZacharyWyatt/DDNS-Using-CloudFlare/blob/main/cf-permissions.jpg?raw=true)

Once you have this script downloaded, you'll adjust the following variables within it:
- **working_dir** - The directory that you will be running the script from [e.g. /home/myuser/scripts/]
- **domain** - The domain in CloudFlare that points to your public IP [e.g. example.com]
- **proxied** - Should the domain name we are using for DDNS be proxied through CloudFlare? True or false
- **get_pub_ip_url** - The URL the script should visit to get your public IP address

There are serveral sites you can use for the value of **get_pub_ip_url**. As long as `curl $get_pub_ip_url` returns only an IP address, the URL can be used for this variable. Here's some such URLs that I know of:
```
http://ipinfo.io/ip
http://ipecho.net/plain
http://ifconfig.me
http://icanhazip.com
http://api.ipify.org
```

- **cf_api_token** - the API token you generated at CloudFlare [e.g. "example-bj6bME6KEu1Bfny6eNwJMVJBEf0PRyZl"]
- **cf_api_url** - Your CloudFlare API endpoint URL

The CloudFlare API endpoint URL is structured like hxxps://api.cloudflare.com/client/v4/zones/**Zone ID**/dns_records/**DNS Record ID**

You can get your **Zone ID** from the domain's overview in CloudFlare.

For the individual **DNS record ID**, you can get it by running the following command, substituting your own **Zone ID**, **domain name**, and **API token**.
```
curl -X GET "https://api.cloudflare.com/client/v4/zones/(Zone ID)/dns_records/dns_records?name=example.com" \
    -H "Authorization: Bearer example-bj6bME6KEu1Bfny6eNwJMVJBEf0PRyZl" \
    -H "Content-Type: application/json"
```
Once the script is set up, you can test it by pointing the domain's A record to a different IP than your own, running the script, and then checking to make sure the IP has been updated.

You can run the script automatically with a crontab entry like:
```
*/3 * * * * /home/myuser/scripts/cf-ddns.sh
```

I also use the CloudFlare API and a domain name to update my resolving nameservers' access control list with my public IP, and I plan on uploading that script soon.
