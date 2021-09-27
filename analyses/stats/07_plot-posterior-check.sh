#!/bin/sh
set -eu -o pipefail

printf "\n\n>>>>>>>>>> Running R posterior plot script.\n\n"
Rscript 07_plot-posterior-check.R --args $1
