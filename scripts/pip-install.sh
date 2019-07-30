#!/usr/bin/env bash

set -x

cd req
pip install pip-tools
pip-compile -v req.in
pip-sync req.txt
