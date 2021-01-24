#!/bin/sh

APIKEY=""
DOMAIN="example.com"
HOSTLIST=("" "www" "hello")
IP=${1}

for HOST in "${HOSTLIST[@]}"
do
	if [ -z "$HOST" ]; then
	  FULLDOMAIN=$DOMAIN
	else
	  FULLDOMAIN=$HOST.$DOMAIN
	fi

	# Fetch DNS record ID
	RESPONSE="$(curl -s "https://www.namesilo.com/api/dnsListRecords?version=1&type=xml&key=$APIKEY&domain=$DOMAIN")"
	RECORD_ID="$(echo $RESPONSE | sed -n "s/^.*<record_id>\(.*\)<\/record_id>.*<type>A<\/type><host>$FULLDOMAIN<\/host>.*$/\1/p")"

	# Update DNS record in Namesilo
	RESPONSE="$(curl -s "https://www.namesilo.com/api/dnsUpdateRecord?version=1&type=xml&key=$APIKEY&domain=$DOMAIN&rrid=$RECORD_ID&rrhost=$HOST&rrvalue=$IP&rrttl=7207")"

	# Check whether the update was successful
	echo $RESPONSE | grep -E "<code>(280|300)</code>" &>/dev/null
	if [ $? -eq 0 ]; then
	  /sbin/ddns_custom_updated 1
	else
	  /sbin/ddns_custom_updated 0
	fi
done

