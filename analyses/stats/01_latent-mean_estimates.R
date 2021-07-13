library(here)
library(cmdstanr)

# load dataframes with estimates
source(here::here('wrangling',
                  '02_prepare-psycholing-data.R'))

d <- filter(d_image, string %in% c('razmisliti', 'sezati')) %>%
    select(-c(mean, median)) %>%
    mutate(string_id = 1:nrow(.)) %>%
    pivot_longer(cols = matches('rater'),
                 names_to = 'rater',
                 values_to = 'rating') %>%
    drop_na()

m_probit <- cmdstanr::cmdstan_model(here::here('stats',
                                               '02_latent-mean_model.stan'))

m_probit_out <- m_probit$sample(data = list('K' = 5,
                                            'N' = length(d$rating),
                                            'S' = max(d$string_id),
                                            'string_id' = d$string_id,
                                            'c_1' = 1.5,
                                            'c_4' = 4.5,
                                            'Y' = d$rating),
                                chains = 6,
                                iter_warmup = 3e3,
                                iter_sampling = 5e3)
