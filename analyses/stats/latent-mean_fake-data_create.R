library(here)
library(dplyr)
library(tidyr)
library(cmdstanr)
library(stringr)
library(magrittr)
library(readr)

m_probit <- cmdstanr::cmdstan_model(here::here('stats',
                                               'latent-mean_fake-data.stan'))

.m_probit_samples <- m_probit$sample(data = list('K' = 5,
                                                 'N' = 35,
                                                 'c_1' = 1.5,
                                                 'c_4' = 4.5),
                                     seed = 1,
                                     chains = 1,
                                     parallel_chains = 1,
                                     iter_warmup = 0,
                                     iter_sampling = 1000,
                                     fixed_param = T)

.draws <- .m_probit_samples$draws() %>%
    as_tibble(.) %>%
    janitor::clean_names(.)

colnames(.draws) %<>%
    stringr::str_replace(.,
                         '^x\\d_',
                         '')

.draws %<>%
    dplyr::select(.,
                  -c('c_2_2', 'c_3_2'))

.draws %<>%
    dplyr::mutate(.iter = 1:nrow(.))

.draws %<>%
    tidyr::pivot_longer(.,
                        cols = matches('y_rep_\\d+'),
                        names_pattern = 'y_rep_(\\d+)',
                        names_to = 'sample',
                        values_to = 'rating') %>%
    mutate(.,
           dplyr::across('sample',
                         as.integer))

readr::write_csv(.draws,
                 here('stats',
                      'latent-mean_fake-data.csv'))
