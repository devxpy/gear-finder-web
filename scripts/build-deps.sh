#!/usr/bin/env bash

docker run \
    -v $PWD:$PWD \
    -v $HOME/.cache/pip:/root/.cache/pip \
    -w $PWD \
    python:3.8 \
    pip install -r req/req.txt --target deps

cd deps
tar -cjf ../gear_finder_deps.tar.bz2 .
cd ..
rm -r deps
