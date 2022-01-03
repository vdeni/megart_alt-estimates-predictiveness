library(here)
library(loo)

loo_mean <- readRDS(here::here('stats',
                               'model-out-data_mean',
                               'loo_mean.RData'))

loo_median <- readRDS(here::here('stats',
                                 'model-out-data_median',
                                 'loo_median.RData'))

loo_latent_mean <- readRDS(here::here('stats',
                                      'model-out-data_latent-mean',
                                      'loo_latent-mean.RData'))

loo::loo_compare(loo_mean,
                 loo_median,
                 loo_latent_mean)
