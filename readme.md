# Basic Docker distribution Opigno 3.0.9

_Credit to [Vabue](https://github.com/vabue/opigno-docker)_

The dockerfile and supporting files were almost entirely generated using ChatGPT and providing feedback. ChatGPT would often change previous commands while updating and refining current commands being debugged. The best of each command was kept.

To install run:

```bash
sudo DOCKER_BUILDKIT=1 docker-compose up -d
```

in the project directory.

In the docker-compose file, besure to update TRUSTED_HOSTS and SITE_URL. They should look similar, but keep the formatting. If you plan on running locally without a custom URL, change to the machines IP and Port, paying attention to if you are using HTTP or HTTPS. (I.E: 192.168.1.10:8080)

Further, update the MariaDB database, user names, and passwords.

Once the container is up and running, navigate to the webpage (your.url.com) and star the opigno installation process.

IMPORTANT: when entering your databse information, you will need to select advanced options and change Host from localhost to mariadb. Because this is using docker networking, the container name can be specified and will connect.

Once your site is running and you are able to navigate the site run this command to change the settings.php permissions:

```bash
docker exec -it opigno chmod 644 sites/default/settings.php
```

Note that when checking your status report, you will get an error/warning to update the drupal core. DO NOT attempt as that breaks certain Opigno Modules, such as the calendar. The Dockerfile already runs a command during build that updates the core to the highest possible without breaking the site.

ADDED FEATURE & CUSTOMIZATION:
The String Overrides module has also be added so you can customize the text on your site directly from the web browser. To use: visit (your.url.com)/admin/settings/stringoverrides or (your.url.com)/admin/config/regional/stringoverrides and fill in the strings you'd like to replace.

For more information on string overrides, visit: https://www.drupal.org/project/stringoverrides
