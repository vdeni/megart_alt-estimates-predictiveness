#!/bin/sh
# run from wrangling.
# get subsample of log likelihoods and calculate rel_eff
set -eu -o pipefail

printf "\n\n>>>>>>>>>> Running R script.\n\n"
Rscript 08_subsample-rt-rep.R --args $1
