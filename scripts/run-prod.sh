#!/usr/bin/env bash

set -ex

./scripts/pre-deploy.sh

python manage.py collectstatic --no-input
python manage.py migrate

gunicorn gear_finder.wsgi --bind unix:/usr/src/app/gunicorn.sock
