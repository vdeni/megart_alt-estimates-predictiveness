library(here)
library(dplyr)
library(magrittr)
library(readr)
library(cmdstanr)

source(here::here('wrangling',
                  'analysis-data_prepare.R'))

m_rt <- cmdstanr::cmdstan_model(here::here('stats',
                                           'reaction-time_model_fake-data.stan'))

.n_subs <- 10
.n_words <- 50
.vec_subs <- rep(1:.n_subs,
                 each = .n_words)
.vec_words <- rep(1:.n_words,
                  each = .n_subs)

.m_rt_samples <- m_rt$sample(data = list('N_SUBS' = .n_subs,
                                         'SUBS' = .vec_subs,
                                         'N_WORDS' = .n_words,
                                         'WORDS' = .vec_words),
                             iter_sampling = 100,
                             fixed_param = T)

.draws <- .m_rt_samples$draws() %>%
    dplyr::as_tibble(.) %>%
    janitor::clean_names(.)

readr::write_csv(.draws,
                 here('stats',
                      'reaction-time_fake-data.csv'))
