#!/bin/sh
# run from wrangling.
# get subsample of log likelihoods and calculate rel_eff
set -eu -o pipefail

printf "\n\n>>>>>>>>>> Running R script.\n\n"
Rscript 06_subsample-rel-eff.R --args $1
