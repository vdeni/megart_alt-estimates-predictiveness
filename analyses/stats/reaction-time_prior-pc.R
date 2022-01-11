# prior predictive checks for stan models

# source analysis data
source(here::here('wrangling',
                  'analysis-data_prepare.R'))

library(here)
library(dplyr)
library(magrittr)
library(cmdstanr)

# compile stan model
m_rt_model <-
    cmdstanr::cmdstan_model(here::here('stats',
                                       'reaction-time_model_prior-pc.stan'))

# use subset of data
.d <- d %>%
    dplyr::filter(.,
                  string %in% head(unique(d$string), 5))

.d_words <- dplyr::filter(d_words,
                          string_id %in% .d$string_id)

# prior predictive check
m_mean <- m_rt_model$sample(data = list('N_OBS' = nrow(.d),
                                        'N_SUBS' = max(.d$id_numeric),
                                        'SUBS' = .d$id_numeric,
                                        'N_WORDS' = max(.d$string_id),
                                        'WORDS' = .d$string_id,
                                        'RT' = .d$stimulus_rt,
                                        'SUBFREQ' = .d_words$subfreq_mean,
                                        'IMAGE' = .d_words$image_mean),
                             iter_sampling = 5e3,
                             fixed_param = T)

d_summary <- m_mean$summary()

dplyr::filter(d_summary,
              stringr::str_detect(variable,
                                  'RT_rep')) %>%
    dplyr::pull(.,
                median) %>%
    quantile(.,
             c(.1, .5, .9))

.draws <- m_mean$draws()

d_draws <- .draws[, , ] %>%
    dplyr::as_tibble(.) %>%
    janitor::clean_names(.) %>%
    dplyr::select(.,
                  contains('rt_rep'))

d_draws %<>%
    dplyr::mutate(.,
                  .iteration = 1:nrow(.)) %>%
    rename_with(.,
                .cols = everything(),
                .fn = stringr::str_replace,
                pattern = '^x1_',
                replacement = '')

apply(d_draws,
      MARGIN = 1,
      FUN = quantile,
      c(.1, .5, .9)) %>%
    apply(.,
          MARGIN = 1,
          FUN = median)
