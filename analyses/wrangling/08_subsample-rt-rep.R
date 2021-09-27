library(here)
library(data.table)

.args <- commandArgs(trailingOnly = T)

data.table::setDTthreads(parallel::detectCores() / 2)

.cmd <- paste("awk 'BEGIN{srand(1)}
              {if (rand() <= .07 || NR == 1) print $0}'",
              here::here('stats',
                         paste0('model-out-data_',
                                .args[2]),
                         paste0('rt-rep_',
                                .args[2],
                                '.csv')))

d_rt_rep <- data.table::fread(cmd = .cmd)

data.table::fwrite(d_rt_rep,
                   file = here::here('stats',
                                     paste0('model-out-data_',
                                            .args[2]),
                                     paste0('d_rt-rep-subsamp_',
                                            .args[2],
                                            '.csv')))
