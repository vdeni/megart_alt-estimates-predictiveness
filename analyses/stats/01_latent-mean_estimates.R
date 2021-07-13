library(here)
library(cmdstanr)

# load dataframes with estimates
source(here::here('wrangling',
                  '02_prepare-psycholing-data.R'))

d <- slice(d_image, 1) %>%
    select(-c(mean, median)) %>%
    pivot_longer(cols = matches('rater'),
                 names_to = 'rater',
                 values_to = 'rating')

m_probit <- cmdstanr::cmdstan_model(here::here('stats',
                                               '02_latent-mean_model.stan'))

m_probit_out <- m_probit$sample(data = list('K' = 5,
                                            'N' = length(d$rating[!is.na(d$rating)]),
                                            'Y' = d$rating[!is.na(d$rating)],
                                            'c_1' = 1.5,
                                            'c_4' = 4.5),
                                chains = 6,
                                iter_warmup = 3e3,
                                iter_sampling = 5e3)
