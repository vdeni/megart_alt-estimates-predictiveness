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
library(ggplot2)
library(cmdstanr)
library(bayesplot)

# compile stan model
m_rt_model <- cmdstanr::cmdstan_model(here::here('stats',
                                                 '03_reaction-time_model.stan'))

# add numeric ID variables for participants and words
d %<>%
    dplyr::group_by(.,
                    id) %>%
    tidyr::nest(.) %>%
    tibble::add_column(.,
                       id_numeric = 1:nrow(.),
                       .after = 1) %>%
    tidyr::unnest(.,
                  cols = 'data') %>%
    dplyr::ungroup(.)

d %<>%
    dplyr::group_by(.,
                    string) %>%
    tidyr::nest(.) %>%
    tibble::add_column(.,
                       string_id = 1:nrow(.),
                       .after = 'string') %>%
    tidyr::unnest(.,
                  cols = 'data') %>%
    dplyr::ungroup(.) %>%
    dplyr::select(.,
                  id,
                  id_numeric,
                  string,
                  string_id,
                  dplyr::everything())

# grand mean-center predictors
d %<>%
    dplyr::mutate(.,
                  dplyr::across(.cols = dplyr::matches('^(image|subfreq)'),
                                .fns = ~c(scale(.x,
                                                scale = F))))

# prior predictive check
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
                             adapt_delta = .80,
                             fixed_param = T)

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
