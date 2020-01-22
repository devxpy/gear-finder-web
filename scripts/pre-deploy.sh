#!/usr/bin/env bash

set -ex

wget -qO deps.tar.bz2 $DEPS_TARBALL
tar -xjf deps.tar.bz2 .

export PYTHONPATH=$PYTHONPATH:$PWD
export PATH=$PATH:$PWD/bin

nohup ./caddy -conf scripts/Caddyfile &
