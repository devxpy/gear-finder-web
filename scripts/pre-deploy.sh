#!/usr/bin/env bash

python setup.py build_ext --inplace
nohup ./caddy -conf scripts/Caddyfile &
