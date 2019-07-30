#!/usr/bin/env bash

set -x

wget -qO deps.tar.bz2 $DEPS_TARBALL
tar -xjf deps.tar.bz2 .

export PYTHONPATH=$PYTHONPATH:$PWD
export PATH=$PATH:$PWD/bin

./scripts/pre-deploy.sh

python manage.py collectstatic --no-input
python manage.py migrate

gunicorn gear_finder.wsgi --bind unix:/usr/src/app/gunicorn.sock
