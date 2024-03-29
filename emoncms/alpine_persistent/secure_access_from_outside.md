# secure access from outside

In order to access to your application from the outside, you have to add a NAT/PAT rule on your internet router.

This involves specifying an internal port and an external port for a local IP. All traffic on your `router's public address:external port` will be routed to the `local IP address:internal port`. 

## about proxies and generating certificates

[NGINX PROXY MANAGER](https://nginxproxymanager.com/) is a reverse proxy, enabling you to access your services securely from the outside, even if these services only offer a non-secure connection. For example, the emoncms standalone docker container without ssl activated does not offer a secure connexion.

You can achieve something similar directling using [nginx](https://hub.docker.com/_/nginx), but nginx proxy manager offers an interface so you dont have to bother with conf files...

If you want to access your services securely from the outside, you need a valid domain name, which may be obtained via duckdns simply by logging in using a github account. This will provide you a token to be supplied when generating the associated certificates needed for securing the connection.

If your IP is fixed, the association with the domain name has to be done only once. If your IP is dynamic, for example if you use an m2m 4G simcard, you will have to manage the updates. Some services do this for free (duckdns) while others like noip require a payment....

The ssl certificates consist of a pair of public and private keys.

Nginx proxy manager runs the whole process for you, ie acts as a proxy and creates/updates the certificates automatically. If you dont use it, [acme.sh](https://github.com/acmesh-official/acme.sh/) is an alternative and probably the simpliest option to manage your certificates using the free solution let's encrypt and many others....

## using nginx proxy manager

To generate the certificates using NGINX PROXY MANAGER, click on `SSL Certificates > Add SSl Certificate > Let's Encrypt`

![image](https://github.com/Open-Building-Management/containers/assets/24553739/a056e47b-6844-433c-b4af-ef92651e329b)

Fill the domain name then choose the `DNS Challenge` method, fill the credentials with your duckdns token, agree to the terms of service and save !

The second step is to create a proxy host, using the domain name with `Websockest Support`, associating the certificate and choosing the `force SSL` option

![image](https://github.com/Open-Building-Management/containers/assets/24553739/93c2b7b7-4121-4edc-837e-8403c50ae450)

**The final stage is to adjust a NAT/PAT rule on your internet router so that the traffic on port 443 goes to the NGINX PROXY MANAGER.**

## about wildcard certificates

You can use wildcard (*.my.domain.name) but they are less and less recommanded : https://en.wikipedia.org/wiki/Wildcard_certificate

with a wildcard | without
--|--
![image](https://github.com/Open-Building-Management/containers/assets/24553739/c5a459b8-647f-4e10-a4ec-79fc175dbebf) | ![image](https://github.com/Open-Building-Management/containers/assets/24553739/87a7f362-fd0f-49f9-8b4c-f70aa9569497)
