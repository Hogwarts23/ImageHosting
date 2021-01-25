#!/opt/bin/bash

API_KEY=""
MyDomain="example.com"
HostA=""
HostB="www"
# HostC=""
renew_hostip()
{
        local   response_xml rspinfo
        local   record_id host_ip
        local   wan0_ip get_ip

        #Taobao API get public ip / Response Format:ipCallback({ip:"1.1.1.1"})
        # get_ip=$(curl -s "http://www.taobao.com/help/getip.php")
        # wan0_ip=$(echo ${get_ip} | sed 's/^.*ip\:\"\([0-9\.]*\).*$/\1/')
        wan0_ip="$(curl -fs4 https://myip.dnsomatic.com/)"
	#Asus Router Merlin FW Get Wan IP
#       wan0_ip=$(nvram get wan0_ipaddr)

        #Get dnsListRecords
        response_xml=$(curl -s "https://www.namesilo.com/api/dnsListRecords?version=1&type=xml&key=${API_KEY}&domain=${MyDomain}")

        echo "Get Record_ID!"
        if [ "$1"x == ""x ]; then
                record_id=$(echo ${response_xml} | sed "s/^.*<record_id>\([0-9a-z]*\)<\/record_id><type>A<\/type><host>${MyDomain}<\/host>.*$/\1/")
                if [[ ${#record_id} -gt 30 ]] && [[ ${#record_id} -lt 34 ]]; then
                        echo "DNS Record ID of ${MyDomain} Is: ${record_id}"
                else 
                        echo "$1.${MyDomain} Record Does No Exist!"
                fi
        else
                record_id=$(echo ${response_xml} | sed "s/^.*<record_id>\([0-9a-z]*\)<\/record_id><type>A<\/type><host>$1\.${MyDomain}<\/host>.*$/\1/")
                if [[ ${#record_id} -gt 30 ]] && [[ ${#record_id} -lt 34 ]]; then
                        echo "DNS Record ID of $1.${MyDomain} Is: ${record_id}"
                else
                        echo "$1.${MyDomain} Record Does No Exist!"
                fi
        fi

        #See If Host Record ID No Exist? Create New One!
        if [[ ${#record_id} -gt 34 ]] || [[ ${#record_id} -lt 30 ]]; then
                echo "Create A New Record!"
                rspinfo=$(curl -s "https://www.namesilo.com/api/dnsAddRecord?version=1&type=xml&key=${API_KEY}&domain=${MyDomain}&rrtype=A&rrhost=$1&rrvalue=${wan0_ip}&rrttl=3602")
                return 0;
        fi

        echo "Get Host's IP"
        if [ "$1"x == ""x ]; then
                host_ip=$(echo ${response_xml} | sed "s/^.*<host>${MyDomain}<\/host><value>\([0-9\.]*\)<\/value>.*$/\1/")
                echo "Host's IP of ${MyDomain} Is: ${host_ip}"
        else 
                host_ip=$(echo ${response_xml} | sed "s/^.*<host>$1\.${MyDomain}<\/host><value>\([0-9\.]*\)<\/value>.*$/\1/")
                echo "Host's IP of $1.${MyDomain} Is: ${host_ip}"
        fi

        #See If Wan IP Is Changed ?
        if [ "${wan0_ip}" == "${host_ip}" ]; then
                echo "IP hasn't changed, don't need updata!"
                return 0
        fi

        echo "Update Host IP!"
        rspinfo=$(curl -s "https://www.namesilo.com/api/dnsUpdateRecord?version=1&type=xml&key=${API_KEY}&domain=${MyDomain}&rrid=${record_id}&rrhost=$1&rrvalue=${wan0_ip}&rrttl=3602")
#       echo ${rspinfo}

        return 0
}

date +%D%t%H:%M:%S
echo "*****************************************"
renew_hostip	${HostA}
echo "-----------------------------------------"
renew_hostip	${HostB}
echo "*****************************************"
# renew_hostip	${HostC}
# echo "*****************************************"
exit 0

# APIKEY=""
# DOMAIN="example.com"
# # HOSTLIST=("" "www" "hello")
# HOST="www"
# IP=${1}

# # for HOST in "${HOSTLIST[@]}"
# # do
# if [ -z "$HOST" ]; then
#   FULLDOMAIN=$DOMAIN
# else
#   FULLDOMAIN=$HOST.$DOMAIN
# fi
# 	# Fetch DNS record ID
# RESPONSE="$(curl -s "https://www.namesilo.com/api/dnsListRecords?version=1&type=xml&key=$APIKEY&domain=$DOMAIN")"
# RECORD_ID="$(echo $RESPONSE | sed -n "s/^.*<record_id>\(.*\)<\/record_id>.*<type>A<\/type><host>$FULLDOMAIN<\/host>.*$/\1/p")"
# 	# Update DNS record in Namesilo
# RESPONSE="$(curl -s "https://www.namesilo.com/api/dnsUpdateRecord?version=1&type=xml&key=$APIKEY&domain=$DOMAIN&rrid=$RECORD_ID&rrhost=$HOST&rrvalue=$IP&rrttl=7207")"
# 	# Check whether the update was successful
# echo $RESPONSE | grep -E "<code>(280|300)</code>" &>/dev/null
# if [ $? -eq 0 ]; then
#   /sbin/ddns_custom_updated 1
# else
#   /sbin/ddns_custom_updated 0
# fi
# # done

