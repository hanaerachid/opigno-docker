# Enhanced docker distribution of Opigno LMS

This project started as before Opigno created thier own docker image. However, their current image does not include apache webserver.

This image includes apache as well as the ability to easily load your own custom settings through a custom.settings.php file (see example docker compose and custom.settings.php file)

To install run:

```bash
sudo DOCKER_BUILDKIT=1 docker-compose up -d
```

in the project directory.

In the docker-compose file, besure to update the MariaDB database, user names, and passwords.

You can choose to not use custom.settings.php and the site will run on local ip and localhost. However, if you plan to use a custom domain and/or reverse proxy, be sure to use and customize the settings found there. Feel free to also add your own settings.

Once the container is up and running, navigate to the webpage (your.url.com) and star the opigno installation process.

IMPORTANT: when entering your databse information, you will need to select advanced options and change Host from localhost to mariadb. Because this is using docker networking, the container name can be specified and will connect.

Once your site is running and you are able to navigate the site, run this command to change the settings.php permissions:

```bash
docker exec -it opigno chmod 644 /var/www/html/web/sites/default/settings.php
```

Note DO NOT update the base calendar module from Drupal, as it is not compatible currently with the Opigno calendar and will break it.

## Additional features and customization:

The String Overrides module has also be added so you can customize the text on your site directly from the web browser. 

To enable, visit (your.url.com)/admin/modules and install it from the list. Update your other modules while youre there.

To use: visit (your.url.com)/admin/settings/stringoverrides or (your.url.com)/admin/config/regional/stringoverrides and fill in the strings you'd like to replace. Dont forget to go back to the main configuration page and clear the website's cache.

For more information on string overrides, visit: https://www.drupal.org/project/stringoverrides

### TO ENABLE SSL & 443:

This requires modifications to to the Dockerfile that you must do for yourself. I personally use both a reverse proxy and a Cloudflare tunnel, so these steps are not needed for me as those care of the SSL configuration for me. If you would like to use that option, check out this video: [NetworkChuck: Cloudflare Tunnels](https://www.youtube.com%2Fwatch%3Fv%3Dey4u7OUAF3c&usg=AOvVaw3PphOIhvNL11fhIeI2GwHW)

On the commandline of your local machine: use Certbot to generate SSL certificates:

```bash
certbot certonly --standalone -d example.com -d www.example.com
```

Replace "example.com" with your domain name.

Once you have the SSL certificates, copy them into the Docker container by adding the following lines to the Dockerfile:

```bash
COPY --chown=www-data:www-data /path/to/cert/fullchain.pem /etc/ssl/certs/opigno.crt
COPY --chown=www-data:www-data /path/to/cert/privkey.pem /etc/ssl/private/opigno.key
```

Replace "/path/to/cert" with the path to your SSL certificates.

Next, we need to modify the Apache virtual host configuration to use SSL. Add the following lines to the end of the "opigno.conf" file:

```bash
SSLEngine on
SSLCertificateFile /etc/ssl/certs/opigno.crt
SSLCertificateKeyFile /etc/ssl/private/opigno.key
```

We also need to redirect traffic from port 80 to port 443. Add the following lines to the "opigno.conf" file, right after the "DocumentRoot" line:

```bash
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
```

Note that ports 80 and 443 are exposed by the image/container by default so they do not need to be added to the Dockerfile

Build and run the Docker container as usual. When you access the Opigno site, it should automatically redirect you to the SSL version of the site (https://).

### Reverse Proxy

Be sure to use the settings found in custom.settings.php and add your proxy ips. Default cloudflare proxy ips are currently listed.
