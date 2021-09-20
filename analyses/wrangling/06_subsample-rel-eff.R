library(here)
library(data.table)
library(loo)

.args <- commandArgs(trailingOnly = T)

data.table::setDTthreads(parallel::detectCores() / 2)

.cmd <- paste("awk 'BEGIN{srand(1)}
              {if (rand() <= .40 || NR == 1) print $0}'",
              here::here('stats',
                         paste0('model-out-data_',
                                .args[2]),
                         paste0('log-lik_',
                                .args[2],
                                '.csv')))

d_loglik <- data.table::fread(cmd = .cmd)

d_loglik <- exp(as.matrix(d_loglik))

rel_eff <- loo::relative_eff(d_loglik,
                             cores = 20,
                             chain_id = 1:nrow(d_loglik))

saveRDS(rel_eff,
        here::here('stats',
                   paste0('model-out-data_',
                          .args[2]),
                   paste0('rel-eff_',
                          .args[2],
                          '.RData')))
