#!/bin/bash
cwd=$(pwd)
echo  "# Attention: run this in your webroot directory!"
# the project title
read -p "# Enter domainname sample.com to uninstall website: " project

var=${project/%.*/}
db_name="db_"$var
db_user="user_"$var

#removing WordPress Database
echo "Deleting new MySQL database..."
mysql -uroot -e "DROP DATABASE ${db_name};"
echo "Database successfully deleted!"
echo ""
echo "Deleting user..."
sudo mysql -uroot -e "DROP USER '${db_user}'@'localhost';"
echo "User successfully deleted!"
echo ""

rm -r $project
echo "Directory deleted" 
echo "" 
rm /etc/nginx/sites-available/$project.conf
rm /etc/nginx/sites-enabled/$project.conf

echo "nginx conf deleted"