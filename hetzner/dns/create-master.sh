#!/usr/bin/env bash

TAB="$(printf '\t')"
DOMEN="konstanta-dev.pp.ua"
MASTER_IP=""
SLAVE_IP=""
TSIG_KEY="$(tsig-keygen -a hmac-sha512 tsig-key)"

apt-get update && apt-get upgrade -y
apt-get -y i nstall ntpdate ntp mc
apt-get -y install bind9 dnsutils

cp -n /etc/resolv.conf /etc/resolv.conf.bak
echo 'nameserver 127.0.0.1' > /etc/resolv.conf

cp -n /etc/bind/named.conf.options /etc/bind/named.conf.options.bak
tee /etc/bind/named.conf.options >/dev/null <<EOF
options {
${TAB}directory "/var/cache/bind";
${TAB}dnssec-validation auto;
${TAB}allow-query { any; };
${TAB}forwarders { 8.8.8.8; 8.8.4.4; };
${TAB}listen-on-v6 { none; };
};
EOF

cp -n /etc/bind/named.conf /etc/bind/named.conf.bak
echo 'include "/etc/bind/named.conf.zones";' >> /etc/bind/named.conf
tee /etc/bind/named.conf.zones >/dev/null <<EOF
${TAB}zone "${DOMEN}" {
${TAB}type master;
${TAB}file "/etc/bind/zones/master/${DOMEN}";
};
EOF

service bind9 restart

mkdir -p /etc/bind/zones/master
tee /etc/bind/zones/master/${DOMEN} >/dev/null <<EOF
\$TTL    3600
@               IN      SOA     ns.${DOMEN}. ns2.${DOMEN}. (
2024042500      ; Serial
900             ; Refresh
900             ; Retry
3600            ; Expire
3600            ; Minimum
)
@               IN      NS      ns1.${DOMEN}.
@               IN      NS      ns2.${DOMEN}.
@               IN      MX      10      mail.${DOMEN}.
@               IN      A       ${MASTER_IP}
www             IN      CNAME   @
mail            IN      A       ${MASTER_IP}
ns1             IN      A       ${MASTER_IP}
ns2             IN      A       ${MASTER_IP}
EOF

rndc reload

cat /var/log/syslog | grep named

nslookup google.com
dig "@${MASTER_IP}" ukr.net
dig "@${MASTER_IP}" ukr.net +trace