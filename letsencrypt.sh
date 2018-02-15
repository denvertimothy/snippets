# setup new certificate
certbot certonly -n -q --webroot --cert-name <internal name> -w <webroot> -d <domain1> -d <domain2>

# rewnew all certificates
certbot rewnew -n -q
