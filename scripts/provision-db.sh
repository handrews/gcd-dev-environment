#!/usr/bin/env bash

echo "Creating gcdonline database..."
mysql -uroot < /vagrant/sql/init.sql && \
echo "...database created."
