#!/bin/bash
set -e

APP_DIR="/var/www/html"

if [ ! -f "$APP_DIR/public/index.php" ]; then
  echo "First run: copying SuiteCRM 8 into persistent volume..."
  cp -R /usr/src/suitecrm/. "$APP_DIR"
fi

chown -R www-data:www-data "$APP_DIR"
chmod -R 775 "$APP_DIR" || true

cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:${PORT:-80}>
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sed -i "s/Listen 80/Listen ${PORT:-80}/" /etc/apache2/ports.conf

rm -f /etc/apache2/mods-enabled/mpm_*.load
rm -f /etc/apache2/mods-enabled/mpm_*.conf
a2enmod mpm_prefork rewrite headers

echo "* * * * * www-data cd /var/www/html && php -f public/legacy/cron.php > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/suitecrm
chmod 0644 /etc/cron.d/suitecrm
cron

apache2-foreground
