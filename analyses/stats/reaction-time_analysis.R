# train and compare three different models aimed at prediciting reaction times
# of correct responses on a lexical decision taks, based on the ratings of
# subjective frequencies and imageability

.args <- commandArgs(trailingOnly = T)

# source analysis data
source(here::here('wrangling',
                  'analysis-data_prepare.R'))

library(here)
library(dplyr)
library(magrittr)
library(cmdstanr)
library(loo)
library(readr)

# compile stan model
m_rt <- cmdstanr::cmdstan_model(here::here('stats',
                                           'reaction-time_model.stan'))

m_samples <- m_rt$sample(data = list('N_OBS' = nrow(d),
                                     'N_SUBS' = max(d$id_numeric),
                                     'SUBS' = d$id_numeric,
                                     'N_WORDS' = max(d$string_id),
                                     'WORDS' = d$string_id,
                                     'RT' = d$stimulus_rt,
                                     'SUBFREQ' = dplyr::pull(d_words,
                                                             paste0('subfreq_',
                                                                    .args[2])),
                                     'IMAGE' = pull(d_words,
                                                    paste0('image_',
                                                           .args[2]))),
                         chains = 24,
                         parallel_chains = 24,
                         iter_warmup = 1.5e3,
                         iter_sampling = .25e3)

print('>>>>> done sampling. extracting draws')

d_rt_rep <- m_samples$draws(variables = 'RT_rep') %>%
    dplyr::as_tibble(.) %>%
    janitor::clean_names(.)

d_loglik <- m_samples$draws(variables = 'log_lik')

print('>>>>> creating rt_rep outfile')

readr::write_csv(d_rt_rep,
                 here('stats',
                      paste0('reaction-time_analysis_',
                             .args[2],
                             '_rt-rep.csv')))

print('>>>>> creating loglik outfile')

saveRDS(d_loglik,
        here('stats',
             paste0('reaction-time_analysis_',
                    .args[2],
                    '_loglik.RData')))

print('>>>>> generating summaries')
d_summary <- m_samples$summary(rhat = posterior::rhat,
                               ess_bulk = posterior::ess_bulk,
                               ess_tail = posterior::ess_tail,
                               .cores = 12)

print('>>>>> creating summary outfile')

write_csv(m_summary,
          here('stats',
               paste0('reaction-time_analysis_',
                      .args[2],
                      '_summary.csv')))
