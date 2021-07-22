# prior predictive checks for stan models

# source analysis data
source(here::here('wrangling',
                  '03_prepare-analysis-data.R'))

library(here)
library(dplyr)
library(magrittr)
library(cmdstanr)

# compile stan model
m_rt_model <-
    cmdstanr::cmdstan_model(here::here('stats',
                                       '03_reaction-time_model_prior-pc.stan'))

# use subset of data
.d <- d %>%
    dplyr::filter(.,
                  string %in% head(unique(d$string), 5))

# prior predictive check
m_mean <- m_rt_model$sample(data = list('N_obs' = nrow(.d),
                                        'N_subs' = length(unique(.d$id_numeric)),
                                        'subs' = .d$id_numeric,
                                        'N_words' = length(unique(.d$string_id)),
                                        'words' = .d$string_id,
                                        'rt' = .d$stimulus_rt,
                                        'subfreq' = .d$subfreq_mean,
                                        'image' = .d$image_mean),
                             iter_sampling = 5e3,
                             fixed_param = T)
