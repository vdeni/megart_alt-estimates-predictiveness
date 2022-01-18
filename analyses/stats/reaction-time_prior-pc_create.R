library(here)
library(cmdstanr)
library(readr)
library(dplyr)

# compile stan model
m_rt <- cmdstanr::cmdstan_model(here::here('stats',
                                           'reaction-time_model_fake-data.stan'))

# create prior-pc data
.n_subs <- 50
.n_words <- 100
.vec_subs <- rep(1:.n_subs,
                 each = .n_words)
.vec_words <- rep(1:.n_words,
                  each = .n_subs)

.m_rt_samples <- m_rt$sample(data = list('N_SUBS' = .n_subs,
                                         'SUBS' = .vec_subs,
                                         'N_WORDS' = .n_words,
                                         'WORDS' = .vec_words),
                             seed = 1,
                             iter_sampling = 5e2,
                             fixed_param = T)

.draws <- .m_rt_samples$draws(variables = 'RT_rep',
                              format = 'df') %>%
    dplyr::as_tibble(.) %>%
    janitor::clean_names(.)

readr::write_csv(.draws,
                 here('stats',
                      'reaction-time_prior-pc_data.csv'))
