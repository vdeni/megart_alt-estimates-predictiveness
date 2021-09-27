library(here)
library(data.table)
library(loo)

setwd(here::here())

renv::activate()

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

d_loglik <- as.matrix(d_loglik)

rel_eff <- readRDS(here::here('stats',
                              paste0('model-out-data_',
                                     .args[2]),
                              paste0('rel-eff_',
                                     .args[2],
                                     '.RData')))

model_loo <- loo::loo(d_loglik,
                      r_eff = rel_eff,
                      cores = 20,
                      save_psis = T)

saveRDS(model_loo,
        here::here('stats',
                   paste0('model-out-data_',
                          .args[2]),
                   paste0('loo_',
                          .args[2],
                          '.RData')))
