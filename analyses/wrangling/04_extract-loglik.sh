#!/bin/sh
set -eu -o pipefail

if [ "$1" == "mean" ]
    then
        TDIR=../stats/model-out-data_$1
fi

echo "Making tmp directory" $TDIR"/tmp"

mkdir $TDIR/tmp

FILES=$(ls $TDIR/*csv)

for file in $FILES
    do
        echo "Getting" $file
        cp $file $TDIR/tmp/
        echo "Cleaning comments with sed."
        sed -i -e '/^#/d' $TDIR/tmp/$(basename $file)
        printf "\n\n>>>>>>>>>> Running R script.\n\n"
        Rscript 04_extract-loglik.R --args $(basename $file) $1
        printf "\n\n>>>>>>>>>> Removing file copy from tmp.\n\n"
        rm $TDIR/tmp/$(basename $file)
done

echo "Cleaning temp folder."
rm -r $TDIR/tmp
