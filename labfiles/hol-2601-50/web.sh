SITE=$(hostname -f) 
sudo mkdir -p /var/www/${SITE}/public
echo "<html><body><h1>Welcome to the HOL 2601-50 Web Server</h1></body></html>" | sudo tee /var/www/${SITE}/public/index.html > /dev/null
sudo chown -R www-data:www-data /var/www/${SITE}
sudo chmod -R 755 /var/www/${SITE}
sudo bash tee > /etc/apache2/sites-available/${SITE}.conf << EOF
<VirtualHost *:80>
    ServerName $SITE
    DocumentRoot /var/www/${SITE}/public
    <Directory /var/www/${SITE}/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/${SITE}_error.log
    CustomLog \${APACHE_LOG_DIR}/${SITE}_access.log combined
</VirtualHost>
EOF
sudo a2ensite ${SITE}.conf
sudo a2dissite 000-default.conf
sudo a2enmod rewrite
sudo apachectl configtest
sudo systemctl reload apache2