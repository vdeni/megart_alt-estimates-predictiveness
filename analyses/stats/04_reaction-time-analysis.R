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
library(bayesplot)

# compile stan model
m_rt_model <-
    cmdstanr::cmdstan_model(here::here('stats',
                                       '04_reaction-time_model.stan'))

.data <- filter(d,
                string_id %in% sample(unique(d$string_id), 25, replace = F)) %>%
    group_by(string) %>%
    nest() %>%
    tibble::add_column(str_id = 1:nrow(.)) %>%
    unnest('data')

# mean of ratings
.start <- Sys.time()
m_mean <- m_rt_model$sample(data = list('N_obs' = nrow(.data),
                                        'N_subs' = max(.data$id_numeric),
                                        'subs' = .data$id_numeric,
                                        'N_words' = max(.data$str_id),
                                        'words' = .data$str_id,
                                        'rt' = .data$stimulus_rt,
                                        'subfreq' = .data$subfreq_mean,
                                        'image' = .data$image_mean),
                             chains = 2,
                             parallel_chains = 2,
                             iter_warmup = 1e3,
                             iter_sampling = .5e3,
                             adapt_delta = .80)
.end <- Sys.time()

d_summary <- m_mean$summary()

.draws <- m_mean$draws()

d_draws <- .draws[, , ] %>%
    dplyr::as_tibble(.) %>%
    janitor::clean_names(.)

d_draws %>%
    dplyr::mutate(.,
                  .iteration = 1:nrow(.)) %>%
    tidyr::pivot_longer(.,
                        cols = matches('^x'),
                        names_pattern = '^(x)(\\d)_.*',
                        names_to = c('chain', '{.value}'))

bayesplot::mcmc_rank_overlay(.draws, regex_pars = 'mi_A')
