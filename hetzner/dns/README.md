````
# terminal 1
cd itedu/hetzner/dns
chmod +x ./build.sh
./build.sh
````

````
# terminal 2
cd itedu/hetzner/dns
set -o allexport; source .env; set +o allexport

ssh ${CLOUD_SSH_USERNAME}@${CLOUD_NS1} -i ~/.ssh/${CLOUD_SSH_KEY}.key
ssh ${CLOUD_SSH_USERNAME}@${CLOUD_NS2} -i ~/.ssh/${CLOUD_SSH_KEY}.key
````

cat /var/log/syslog | grep named

named-checkconf /etc/bind/named.conf
named-checkzone konstanta.pp.ua /var/named/konstanta.pp.ua.db
service bind9 restart
service bind9 status

nslookup "@${CLOUD_DOMAIN}"

dig @${CLOUD_NS1} ${CLOUD_DOMAIN}
