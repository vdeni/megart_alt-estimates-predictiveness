#!/bin/sh
# run from wrangling.
# get posterior summaries for each variable individually and combine into same
# CSV file
set -eu -o pipefail

VARS=(a_0 mi_b_SUBS sigma_b_SUBS c_0 c_SUBFREQ c_IMAGE\
 sigma_RT sigma_c_WORDS b_SUBS c_WORDS)

if [ "$1" == "mean" ]
    then
        TDIR=../stats/model-out-data_$1
fi

for i in $(seq 0 $(( ${#VARS[@]} - 1)) )
    do
        echo $(( $i + 1 )) "of" $(( ${#VARS[@]} + 1 ))

        printf "\n\n>>>>>>>>>> Running R script.\n\n"
        Rscript 04_get-summary.R --args $1 ${VARS[$i]}
done
