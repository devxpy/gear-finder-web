#!/usr/bin/env bash

set -x

wget -qO deps.tar.bz2 "https://saral-data-bucket.s3.ap-south-1.amazonaws.com/dev/deps.tar.bz2"
tar -xjf deps.tar.bz2 .

export PYTHONPATH=$PYTHONPATH:$PWD
export PATH=$PATH:$PWD/bin

python setup.py install

python manage.py collectstatic --no-input
python manage.py migrate

nohup ./caddy &
gunicorn config.wsgi --bind unix:/usr/src/app/gunicorn.sock
