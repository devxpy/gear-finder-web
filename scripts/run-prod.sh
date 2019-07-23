#!/usr/bin/env bash

set -x

tar -xjf deps.tar.bz2
export PYTHONPATH=$PYTHONPATH:$PWD
export PATH=$PATH:$PWD/bin

python python setup.py install

python manage.py collectstatic --no-input
python manage.py migrate

nohup caddy &
gunicorn config.wsgi --bind unix:/usr/src/app/gunicorn.sock
