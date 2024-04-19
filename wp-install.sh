#!/bin/bash
# bash script written by Jessonle Solana - github.com/jtsolana

cwd=$(pwd)
echo "wordpress deployment (wp-cli based)"
# get the data in
echo  "# Attention: run this in your webroot directory!"
# the project title
read -p "# Enter domain name sample.com: " project
var=${project/%.*/}

# generate a random password
generate_password() {
    # define the characters to use in the password
    chars='!@#$%^&*()_+{}[]<>?abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    #generate a password of length 12
    password=$(tr -dc "$chars" < /dev/urandom | fold -w 12 | head -n 1)
    echo "$password"
}

db_name="db_"$var
db_user="user_"$var
db_user_pass=$(generate_password)

# setup wordpress database
echo "Creating new MySQL database..."
mysql -uroot -e "CREATE DATABASE ${db_name} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
echo "Database successfully created!"
echo ""
echo "Creating new user..."
sudo mysql -uroot -e "CREATE USER ${db_user}@localhost IDENTIFIED BY '${db_user_pass}';"
echo "User successfully created!"
echo ""
echo "Granting ALL privileges on ${db_name} to ${db_user}!"
mysql -uroot -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';"
mysql -uroot -e "FLUSH PRIVILEGES;"

echo "Downloading wordpress.."

sudo -u www-data mkdir $project && cd $project 
sudo -u www-data mkdir "public_html" && cd "public_html" && sudo -u www-data wp core download

# connect wordpress to the database
sudo -u www-data wp config create --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_user_pass}

# setup nginx site-config
TEMPLATE="upstream $project-php-handler {
        server unix:/var/run/php/php7.4-fpm.sock;
}
server {
        listen 80;
        server_name $project www.$project;
        root $cwd/$project/public_html;
        index index.php;
        location / {
                try_files \$uri \$uri/ /index.php?\$args;
        }
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass $project-php-handler;
        }
}"

# pipe variable output to sed and save modified outputin to file
echo "$TEMPLATE" | sed s/template/$project/g > /etc/nginx/sites-available/$project.conf

# create symlink in sites-enabled
sudo ln -s /etc/nginx/sites-available/$project.conf /etc/nginx/sites-enabled

# test Nginx configuration changes and restart the web server.
nginx -t
systemctl restart nginx

# install wordpress using wp-cli
wp_user="admin"
wp_user_pass=$(generate_password)
sudo -u www-data wp core install --url=$project --title=$project --admin_user=$wp_user --admin_password=$wp_user_pass --admin_email="admin@sample.com"

echo "installing themes..."
sudo -u www-data wp theme install twentyseventeen --activate

echo "installing plugins..."
sudo -u www-data wp plugin install wordpress-seo --activate

# setup ssl certificate
certbot run -n --nginx --agree-tos -d $project,www.$project  -m  iamjessonle@gmail.com  --redirect


echo "Database Name: $db_name"
echo "Database User: $db_user"
echo "Database Password: $db_user_pass"

echo "Congratulations! You have successfully setup wordpress-site"
echo "https://$project/admin"
echo "username: $wp_user"
echo "password: $wp_user_pass"