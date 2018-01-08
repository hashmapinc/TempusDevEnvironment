# NGINX Configuration

Configuring nginx for reverse proxy with ssl.

###### Generate Keys using following openssl :
```text
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cert.key -out cert.crt
``` 
Provide all the necessary paramters required while creating keys.

#### Nginx mapping to thingsboard on Docker Setup:

- http/https :
```text
ssl 443 (Nginx)   ----> tb:8080
http 80 (Nginx)   ----> 443 (Nginx)   ----> tb:8080
```
- mqtt :
```text
mqtt 1884 (Nginx)  ----> tb:1883
```
- coap :
```text
coap 5684 udp (Nginx)   ----> tb:5683
```
- 9999 :
```text
9998 (Nginx)  ----> tb:9999
```
