#!/usr/bin/env bash

python3 -m venv /opt/venv && \
source /opt/venv/bin/activate && \
pip install -U pip && \
pip install -r /vagrant/www/requirements.txt
