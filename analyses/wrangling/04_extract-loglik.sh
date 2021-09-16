#!/bin/sh
set -eu -o pipefail

if [ "$1" == "mean" ]
    then
        TDIR=../stats/model-out-data_$1
fi

echo "Making tmp directory" $TDIR"/tmp"

mkdir $TDIR/tmp

for file in $(ls $TDIR/*csv)
    do
        echo "Getting" $file
        cp $file $TDIR/tmp/
        echo "Cleaning comments with sed."
        sed -i -e '/^#/d' $TDIR/tmp/$(basename $file)
        printf "\n\n>>>>>>>>>> Running R script.\n\n"
        Rscript 04_extract-loglik.R --args $(basename $file) $1
done

echo "Cleaning temp folder."
rm -r $TDIR/tmp
