#!/usr/bin/env bash

echo "Downloading and installing elasticsearch..."
wget -q \
  https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.4.5.deb \
  https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.4.5.deb.sha1.txt && \
sha1sum elasticsearch-1.4.5.deb | diff elasticsearch-1.4.5.deb.sha1.txt - && \
sudo dpkg -i elasticsearch-1.4.5.deb && \
sudo /etc/init.d/elasticsearch start && \
cd /vagrant/www && \
echo "Running the initial search index update..."
python manage.py update_index && \
echo "Search index initialized!"
