<?php
$settings['file_public_base_url'] = 'https://www.example.com/sites/default/files';
$settings['file_private_path'] = '/var/www/html/private';
$settings['trusted_host_patterns'] = [
   '^.+\.example\.com$',
 ];
$settings['reverse_proxy'] = TRUE;
# includes reverse proxy addresss for cloudflare. Dont forget to add in your reverse proxy ips
$settings['reverse_proxy_addresses'] = ['173.245.48.0/20', '103.21.244.0/22', '103.22.200.0/22', '103.31.4.0/22', '141.101.64.0/18', '108.162.192.0/18', '190.93.240.0/20', '188.114.96.0/20', '197.234.240.0/22', '198.41.128.0/17', '162.158.0.0/15', '104.16.0.0/13', '104.24.0.0/14', '172.64.0.0/13', '131.0.72.0/22'];
$settings['reverse_proxy_trusted_headers'] = \Symfony\Component\HttpFoundation\Request::HEADER_X_FORWARDED_FOR | \Symfony\Component\HttpFoundation\Request::HEADER_FORWARDED;
