#!/usr/bin/env bash

set -ex

wget -qO deps.tar.bz2 $DEPS_TARBALL
tar -xjf deps.tar.bz2 .

export PYTHONPATH=$PYTHONPATH:$PWD
export PATH=$PATH:$PWD/bin

python setup.py build_ext --inplace
nohup ./caddy -conf scripts/Caddyfile &
