#!/usr/bin/env bash

set -ex

docker run \
    -v $PWD:$PWD \
    -v $HOME/.cache/pip:/root/.cache/pip \
    -w $PWD \
    python:3.8 \
    "$@"
