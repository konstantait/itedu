#!/usr/bin/env bash
# shellcheck disable=2154
# shellcheck disable=2034
# shellcheck disable=2129

# /etc/resolv.conf
echo 'nameserver 127.0.0.1' > /etc/resolv.conf

# /etc/bind/named.conf
echo 'include "/etc/bind/named.conf.zones";' >> /etc/bind/named.conf
cat /etc/bind/tsig.key >> /etc/bind/named.conf
tee -a /etc/bind/named.conf >/dev/null <<EOF
%{ if environment == "master" }
server ${slave_ip} { 
        keys { tsig-key; }; 
};
%{ endif }
%{ if environment == "slave" }
server ${master_ip} { 
        keys { tsig-key; }; 
};
%{ endif }
EOF
echo 'include "/etc/bind/rndc.key";' >> /etc/bind/named.conf

# /etc/bind/named.conf.options
tee /etc/bind/named.conf.options >/dev/null <<EOF
options {
    directory "/var/cache/bind";
    dnssec-validation auto;
    allow-query { any; };
    forwarders { 8.8.8.8; 8.8.4.4; };
    listen-on-v6 { none; };
};
EOF

# /etc/bind/named.conf.zones
tee /etc/bind/named.conf.zones >/dev/null <<EOF
%{ if environment == "master" }
zone "${domain}" {
    type master;
    file "/etc/bind/zones/master/${domain}";
};
%{ endif }
%{ if environment == "slave" }
zone "${domain}" {
    type slave;
    file "/etc/bind/zones/slave/${domain}";
};
%{ endif }
EOF

# /etc/bind/zones/master or /etc/bind/zones/slave

mkdir -p "/etc/bind/zones/${environment}"

tee "/etc/bind/zones/${environment}/${domain}" >/dev/null <<EOF
%{ if environment == "master" }
\$TTL    3600
@               IN      SOA     ns1.${domain}. ns2.${domain}. (
2024042500      ; Serial
900             ; Refresh
900             ; Retry
3600            ; Expire
3600            ; Minimum
)
@               IN      NS      ns1.${domain}.
@               IN      NS      ns2.${domain}.
@               IN      MX      10      mail.${domain}.
@               IN      A       ${master_ip}
www             IN      CNAME   @
mail            IN      A       ${master_ip}
ns1             IN      A       ${master_ip}
ns2             IN      A       ${slave_ip}
%{ endif }
EOF

service bind9 restart

rndc reload
