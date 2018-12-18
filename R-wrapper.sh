#!/bin/bash

EXPECTED_ARGS=1

if [ $# -ne $EXPECTED_ARGS ]; then
  echo "Usage: R-wrapper.sh file.R"
  exit 1
else
  module load r
  Rscript $1
fi
