#!/bin/sh

if [ "$1" == "mean" ]
    then
        TDIR=../stats/model-out-data_$1
fi

for file in $(ls $TDIR/*csv)
    do
        echo "Getting" $file
        echo "Cleaning comments with sed."
        sed -i -e '/^#/d' $file
        Rscript 04_extract-loglik.R --args $file $1
    done
