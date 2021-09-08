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

.d <- filter(d,
                string_id %in% sample(unique(d$string_id), 250, replace = F)) %>%
    group_by(string) %>%
    nest() %>%
    tibble::add_column(str_id = 1:nrow(.)) %>%
    unnest('data')

.d_words <- filter(d_words,
                   string_id %in% .d$string_id)

# mean of ratings
.start <- Sys.time()
m_mean <- m_rt_model$sample(data = list('N_OBS' = nrow(.d),
                                        'N_SUBS' = max(.d$id_numeric),
                                        'SUBS' = .d$id_numeric,
                                        'N_WORDS' = max(.d$str_id),
                                        'WORDS' = .d$str_id,
                                        'RT' = .d$stimulus_rt,
                                        'SUBFREQ' = .d_words$subfreq_mean,
                                        'IMAGE' = .d_words$image_mean),
                             chains = 4,
                             parallel_chains = 4,
                             iter_warmup = 2e3,
                             iter_sampling = 1.5e3,
                             adapt_delta = .80,
                             max_treedepth = 11)
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
