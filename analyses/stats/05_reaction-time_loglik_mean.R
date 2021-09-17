library(here)
library(data.table)

d_loglik <- as.matrix(data.table::fread(file = here::here('stats',
                                                          'model-out-data_mean',
                                                          'log-lik_mean.csv')))

# convert to matrix for loo()
d_loglik <- as.matrix(d_loglik)
