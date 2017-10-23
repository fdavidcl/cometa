#!/bin/bash

set -e

if [ -t 0 ] ; then
    ruby init.rb
else
    ruby launch.rb
fi
# /bin/bash -c "$@"
