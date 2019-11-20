#!/usr/bin/env bash

python3 -m venv /opt/venv && \
echo "source /opt/venv/bin/activate" >> /home/vagrant/.bash_profile && \
source /opt/venv/bin/activate && \
pip install -U pip && \
pip install -r /vagrant/www/requirements.txt
