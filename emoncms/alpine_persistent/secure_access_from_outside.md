# secure access from outside

If you don't use a reverse proxy and wish to access to your application from the outside, you have to add a NAT/PAT rule on your internet router.

This involves specifying an internal port and an external port for a local IP. All traffic on your `router's public address:external port` will be routed to the `local IP address:internal port`.

You can use your public IP if fixed or a dynamic dns, for example supplied by noip or by duckdns.

## about proxies and generating certificates with let's encrypt

In all cases, [NGINX PROXY MANAGER](https://nginxproxymanager.com/), which is a reverse proxy, will enable you to access your services securely from the outside, even if these services only offer a non-secure connection. For example, the emoncms standalone docker container without ssl activated does not offer a secure connexion.

If you want to access your services securely from the outside, you need a valid domain name, which may be obtained via duckdns simply by logging in using a github account. This will provide you a token to be supplied when generating the associated certificates needed for securing the connection. 

Certificates consist of a pair of public and private keys.

To generate them using NGINX PROXY MANAGER, click on `SSL Certificates > Add SSl Certificate > Let's Encrypt`

![image](https://github.com/Open-Building-Management/containers/assets/24553739/a056e47b-6844-433c-b4af-ef92651e329b)

Fill the domain name then choose the `DNS Challenge` method, fill the credentials with your duckdns token, agree to the terms of service and save !

You can use wildcard (*.my.domain.name) but they are less and less recommanded : https://en.wikipedia.org/wiki/Wildcard_certificate

The second step is to create a proxy host, using the domain name with `Websockest Support`, associating the certificate and choosing the `force SSL` option

![image](https://github.com/Open-Building-Management/containers/assets/24553739/93c2b7b7-4121-4edc-837e-8403c50ae450)

**The final stage is to adjust a NAT/PAT rule on your internet router so that the traffic on port 443 goes to the NGINX PROXY MANAGER.**
