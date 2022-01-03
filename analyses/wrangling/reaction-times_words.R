# extract word strings present in the reaction time data
library(here)

.args <- commandArgs(trailingOnly = T)

source(here::here('wrangling',
                  'reaction-times_merge.R'))

strings <- dplyr::select(d_rt,
                         'string')

strings <- select(strings,
                  'string') %>%
                   dplyr::distinct(.)

readr::write_csv(strings,
                 here('data',
                      'reaction-times',
                      .args[2]))
