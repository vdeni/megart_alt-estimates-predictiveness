#!/bin/sh
set -eu -o pipefail

cd ..

printf "\n\n>>>>>>>>>> Running R script.\n\n"
Rscript stats/05_reaction-time_loglik.R --args $1
