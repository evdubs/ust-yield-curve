#!/usr/bin/env bash

today=$(date "+%F")
dir=$(dirname "$0")
current_year=$(date "+%Y")

racket ${dir}/extract.rkt
racket ${dir}/transform-load.rkt -p "$1"

7zr a /var/tmp/ust/yield-curve/${current_year}.7z /var/tmp/ust/yield-curve/${today}.xml
