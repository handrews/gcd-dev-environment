#!/usr/bin/env bash

cat > /vagrant/www/settings_local.py <<EOD
ALLOWED_HOSTS = [
    'localhost',
]

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake'
    }
}

SILENCED_SYSTEM_CHECKS = ['captcha.recaptcha_test_key_error']
EOD

source /opt/venv/bin/activate && \
cd /vagrant/www && \
python manage.py migrate && \
python manage.py loaddata apps/stddata/fixtures/* && \
python manage.py loaddata apps/indexer/fixtures/users.yaml && \
python manage.py loaddata apps/gcd/fixtures/* && \
python manage.py loaddata apps/mycomics/fixtures/* && \
python manage.py loaddata apps/stats/fixtures/* && \
python manage.py loaddata apps/voting/fixtures/*
