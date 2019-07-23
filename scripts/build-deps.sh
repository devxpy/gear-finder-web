#!/usr/bin/env bash

docker run \
    -v $PWD:$PWD \
    -v $HOME/.cache/pip:/root/.cache/pip \
    -w $PWD \
    python \
    pip install -r req/req.txt --target deps

cd deps
tar -cjf ../deps.tar.bz2 .
cd ..
rm -r deps
