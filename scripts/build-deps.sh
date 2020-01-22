#!/usr/bin/env bash

set -ex

pip install . --target deps
cd deps
tar -cjf ../gear_finder_deps.tar.bz2 .
cd ..
rm -r deps
