#!/usr/bin/env bash

set -ex

wget -qO deps.tar.bz2 $DEPS_TARBALL
tar -xjf deps.tar.bz2 .

export PYTHONPATH=$PWD:$PYTHONPATH
export PATH=$PWD/bin:$PATH

python setup.py build_ext --inplace
python manage.py collectstatic --no-input
python manage.py migrate

nohup ./caddy -conf scripts/Caddyfile &
gunicorn gear_finder.wsgi --bind unix:/usr/src/app/gunicorn.sock
