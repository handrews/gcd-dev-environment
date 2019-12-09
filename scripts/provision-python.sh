#!/usr/bin/env bash

echo "creating python3 virtualenv..."
python3 -m venv /opt/venv && \
source /opt/venv/bin/activate && \
echo "updating pip..." && \
pip install -U pip && \
echo "installing GCD requirements..." && \
pip install -r /vagrant/www/requirements.txt && \
echo "...python3 environment provisioned."
