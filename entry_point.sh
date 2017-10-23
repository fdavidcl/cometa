#!/bin/bash

set -e

if [ -t 0 ] ; then
    ruby init.rb menu
else
    ruby init.rb daemon
fi
