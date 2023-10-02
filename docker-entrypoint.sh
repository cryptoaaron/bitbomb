#!/bin/bash

# Check if the first argument is "simplewallet"
if [ "$1" == "simplewallet" ]; then
    shift # Shift all the parameters to the left. $2 becomes $1, etc.
    exec simplewallet "$@"
else
    exec bitbombd "$@"
fi