#!/bin/bash

DB_SAVE_PATH=/home/ubuntu

cd $DB_SAVE_PATH

sudo -S mysqldump -u root -f --all-databases | gzip -9 > db_backup.sql.gz