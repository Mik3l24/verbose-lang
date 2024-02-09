#!/bin/bash

CASE_N=$2

IN_F="$1/tests/$CASE_N.ver"
OUT_F="$1/tests/$CASE_N.ast"
if test -f "$IN_F" && test -f "$OUT_F"; 
then
    #Test
    if cmp --silent "$OUT_F" <($1/build/verbose "$IN_F")
    then
        echo "Difftest $i passed."
        exit 0;
    else
        echo "Difftest $i failed."
        echo "Diff:"
        diff "$OUT_F" <($1/build/verbose "$IN_F")
        exit 1;
    fi
else
    echo "Test file $IN_F or $OUT_F does not exist."
    exit 1
fi

