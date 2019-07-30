#!/usr/bin/env bash

set -x

cd req
pip install -U pip-tools
pip-compile -U -v req.in
pip-sync req.txt
