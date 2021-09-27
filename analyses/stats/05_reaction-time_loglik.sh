#!/bin/sh
set -eu -o pipefail

cd ..

printf "\n\n>>>>>>>>>> Running R script.\n\n"
Rscript 05_reaction-time_loglik.R --args $1
