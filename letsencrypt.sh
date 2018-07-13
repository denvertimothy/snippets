# setup new certificate using webroot authentication
certbot certonly -n -q --webroot --cert-name <internal name> -w <webroot> -d <domain1> -d <domain2> --agree-tos --email <email>

# setup new certificate using standalone authentication
certbot certonly -n -q --standalone --tls-sni-01-port 4443 --http-01-port 8880 --cert-name <internal name> -d <domain1> -d <domain2> --agree-tos --email ian@thrivedata.it

# rewnew all certificates
certbot rewnew -n -q
