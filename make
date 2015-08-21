#!/usr/bin/env bash

if [ "$#" -ne 0 ]; then
    echo "$1" > .last
    make clean
    make lua PLAT="$(cat .last)"
fi

make PLAT="$(cat .last)"
