# read data containing individual estimates of psycholingustic features
library(dplyr)
library(here)
library(magrittr)
library(readr)
library(tidyr)
library(purrr)

##### imageability #####
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

# remove duplicated entries
d_image %<>%
    dplyr::distinct(.)

# some words appeared in both data-collection waves. i'm separating those words
# out into their own dataframe, to get a estimate
v_image_dupes <- d_image[duplicated(d_image$string), 'string'] %>%
    dplyr::pull(.,
                string)

d_image_dupes <- d_image %>%
    dplyr::filter(.,
                  string %in% v_image_dupes)

d_image %<>%
    dplyr::filter(.,
                  !string %in% v_image_dupes)

# get mean and median for non-duplicates
d_image$estimate_mean <- d_image %>%
    dplyr::select(.,
                  matches('^rater')) %>%
    rowMeans(.,
             na.rm = T)

d_image$estimate_median <- d_image %>%
    dplyr::select(.,
                  matches('^rater')) %>%
    apply(.,
          MARGIN = 1,
          FUN = median,
          na.rm = T)

# get mean and median for duplicates
d_image_dupes %<>%
    dplyr::group_by(.,
                    string) %>%
    tidyr::nest(.)

d_image_dupes$data <- d_image_dupes$data %>%
    purrr::map(.,
               .f = ~as.matrix(as.data.frame(.x)))

d_image_dupes$estimate_mean <- d_image_dupes$data %>%
    purrr::map_dbl(.,
                   .f = mean,
                   na.rm = T)

d_image_dupes$estimate_median <- d_image_dupes$data %>%
    purrr::map_dbl(.,
                   .f = median,
                   na.rm = T)

d_image_dupes %<>%
    dplyr::select(.,
                  -data) %>%
    dplyr::ungroup(.)

# combine estimates
d_image %<>%
    dplyr::select(.,
                  -matches('rater'))

d_image <- bind_rows(d_image,
                     d_image_dupes)

rm(d_image_dupes,
   v_image_dupes)

##### subjective frequency #####
d_subfreq <- readr::read_tsv(here::here('data',
                                        'psycholinguistic-estimates',
                                        'subjective-frequency.tsv'),
                           col_names = F,
                           col_types = paste0('c',
                                              paste0(rep('i', 36),
                                                     collapse = '')))

d_subfreq %<>%
    magrittr::set_colnames(.,
                           c('string',
                           paste0('rater_', 1:(ncol(.) - 1))))

# remove duplicated entries
d_subfreq %<>%
    dplyr::distinct(.)

# some words appeared in both data-collection waves. i'm separating those words
# out into their own dataframe, to get a estimate
v_subfreq_dupes <- d_subfreq[duplicated(d_subfreq$string), 'string'] %>%
    dplyr::pull(.,
                string)

d_subfreq_dupes <- d_subfreq %>%
    dplyr::filter(.,
                  string %in% v_subfreq_dupes)

d_subfreq %<>%
    dplyr::filter(.,
                  !string %in% v_subfreq_dupes)

# get mean and median for non-duplicates
d_subfreq$estimate_mean <- d_subfreq %>%
    dplyr::select(.,
                  matches('^rater')) %>%
    rowMeans(.,
             na.rm = T)

d_subfreq$estimate_median <- d_subfreq %>%
    dplyr::select(.,
                  matches('^rater')) %>%
    apply(.,
          MARGIN = 1,
          FUN = median,
          na.rm = T)

# get mean and median for duplicates
d_subfreq_dupes %<>%
    dplyr::group_by(.,
                    string) %>%
    tidyr::nest(.)

d_subfreq_dupes$data <- d_subfreq_dupes$data %>%
    purrr::map(.,
               .f = ~as.matrix(as.data.frame(.x)))

d_subfreq_dupes$estimate_mean <- d_subfreq_dupes$data %>%
    purrr::map_dbl(.,
                   .f = mean,
                   na.rm = T)

d_subfreq_dupes$estimate_median <- d_subfreq_dupes$data %>%
    purrr::map_dbl(.,
                   .f = median,
                   na.rm = T)

d_subfreq_dupes %<>%
    dplyr::select(.,
                  -data) %>%
    dplyr::ungroup(.)

# combine estimates
d_subfreq %<>%
    dplyr::select(.,
                  -matches('rater'))

d_subfreq <- bind_rows(d_subfreq,
                       d_subfreq_dupes)

rm(d_subfreq_dupes,
   v_subfreq_dupes)
