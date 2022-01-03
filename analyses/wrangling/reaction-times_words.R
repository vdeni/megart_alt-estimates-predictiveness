# extract word strings present in the reaction time data
library(here)

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
                      'reaction-times_words.csv'))
