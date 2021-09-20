# train and compare three different models aimed at prediciting reaction times
# of correct responses on a lexical decision taks, based on the ratings of
# subjective frequencies and imageability

# source analysis data
source(here::here('wrangling',
                  '03_prepare-analysis-data.R'))

library(here)
library(dplyr)
library(tidyr)
library(magrittr)
library(cmdstanr)

# compile stan model
m_rt_model <-
    cmdstanr::cmdstan_model(here::here('stats',
                                       '04_reaction-time_model.stan'))

# median of ratings
m_median <- m_rt_model$sample(data = list('N_OBS' = nrow(d),
                                        'N_SUBS' = max(d$id_numeric),
                                        'SUBS' = d$id_numeric,
                                        'N_WORDS' = max(d$string_id),
                                        'WORDS' = d$string_id,
                                        'RT' = d$stimulus_rt,
                                        'SUBFREQ' = d_words$subfreq_median,
                                        'IMAGE' = d_words$image_median),
                             chains = 24,
                             parallel_chains = 24,
                             iter_warmup = 1e3,
                             iter_sampling = 1e3,
                             adapt_delta = .80,
                             max_treedepth = 11)
