#!/usr/bin/env bash

set -ex

rm -r deps
pip install . --target deps
cd deps
tar -cjf ../gear_finder_deps.tar.bz2 .
cd ..
