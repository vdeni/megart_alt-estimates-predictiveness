# read data containing individual estimates of psycholingustic features
library(dplyr)
library(here)
library(magrittr)
library(readr)

# read imageability data
d_image <- readr::read_tsv(here::here('data',
                                      'psycholinguistic-estimates',
                                      'imageability.tsv'),
                           col_names = F,
                           col_types = paste0('c',
                                              paste0(rep('i', 35),
                                                     collapse = '')))

d_image %<>%
    magrittr::set_colnames(.,
                           c('string',
                           paste0('rater_', 1:(ncol(.) - 1))))
