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

.data <- filter(d, string %in% head(unique(d$string), 100))

# mean of ratings
.start <- Sys.time()
m_mean <- m_rt_model$sample(data = list('N_obs' = nrow(.data),
                                        'N_subs' = length(unique(.data$id_numeric)),
                                        'subs' = .data$id_numeric,
                                        'N_words' = length(unique(.data$string_id)),
                                        'words' = .data$string_id,
                                        'rt' = .data$stimulus_rt,
                                        'subfreq' = .data$subfreq_mean,
                                        'image' = .data$image_mean),
                             chains = 6,
                             parallel_chains = 6,
                             iter_warmup = 3e3,
                             iter_sampling = 6e3,
                             adapt_delta = .80)
.end <- Sys.time()
