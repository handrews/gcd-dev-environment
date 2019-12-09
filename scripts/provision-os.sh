#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
 
echo "updating debian packages..."
apt-get update && \
apt-get upgrade -y && \
apt-get install -y build-essential
apt-get install -y git python3-dev python3-venv \
                   libicu-dev libjpeg-dev libpng-dev zlib1g-dev \
                   mysql-server default-libmysqlclient-dev && \
echo "...debian packages updated."
