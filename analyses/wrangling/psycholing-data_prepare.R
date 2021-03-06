# read data containing individual estimates of psycholingustic features and
# calculate mean and median estimates
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
# out into their own dataframe
v_image_dupes <- d_image[duplicated(d_image$string), 'string'] %>%
    dplyr::pull(.,
                string)

d_image_dupes <- d_image %>%
    dplyr::filter(.,
                  string %in% v_image_dupes)

d_image %<>%
    dplyr::filter(.,
                  !string %in% v_image_dupes)

# concatenating raters' estimates for words appearing in both data-collection
# waves
d_image_dupes %<>%
    dplyr::group_by(.,
                    string) %>%
    tidyr::nest(.)

d_image_dupes$data <- d_image_dupes$data %>%
    purrr::map(.,
               .f = ~matrix(unlist(as.data.frame(.x)),
                            nrow = 1))

n_raters <- purrr::map_int(d_image_dupes$data,
                           ncol) %>%
    max(.)

d_image_dupes$data <- d_image_dupes$data %>%
    purrr::map(.,
               ~magrittr::set_colnames(.x,
                                       paste0('rater_',
                                              1:n_raters)))

d_image_dupes <- d_image_dupes$data %>%
    purrr::map(.,
               dplyr::as_tibble) %>%
    purrr::reduce(.,
                  dplyr::bind_rows) %>%
    dplyr::bind_cols(d_image_dupes,
                     .) %>%
    dplyr::select(.,
                  -data) %>%
    dplyr::ungroup(.)

# combine ratings in the two dataframes
d_image <- dplyr::bind_rows(d_image,
                            d_image_dupes)

# get mean and median
d_image$mean <- d_image %>%
    dplyr::select(.,
                  matches('rater')) %>%
    rowMeans(.,
             na.rm = T)

d_image$median <- d_image %>%
    dplyr::select(.,
                  matches('rater')) %>%
    apply(.,
          MARGIN = 1,
          median,
          na.rm = T)

rm(d_image_dupes,
   v_image_dupes,
   n_raters)

# filter out strings not present in reaction time data
d_rt_words <- readr::read_csv(here::here('data',
                                         'reaction-times',
                                         'reaction-times_words.csv'))

d_image <- d_image %>%
    dplyr::filter(.,
                  string %in% d_rt_words$string)

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
                             paste0('rater_',
                                    1:(ncol(.) - 1))))

# remove duplicated entries
d_subfreq %<>%
    dplyr::distinct(.)

# some words appeared in both data-collection waves. i'm separating those words
# out into their own dataframe
v_subfreq_dupes <- d_subfreq[duplicated(d_subfreq$string), 'string'] %>%
    dplyr::pull(.,
                string)

d_subfreq_dupes <- d_subfreq %>%
    dplyr::filter(.,
                  string %in% v_subfreq_dupes)

d_subfreq %<>%
    dplyr::filter(.,
                  !string %in% v_subfreq_dupes)

# concatenating raters' estimates for words appearing in both data-collection
# waves
d_subfreq_dupes %<>%
    dplyr::group_by(.,
                    string) %>%
    tidyr::nest(.)

d_subfreq_dupes$data <- d_subfreq_dupes$data %>%
    purrr::map(.,
               .f = ~matrix(unlist(as.data.frame(.x)),
                            nrow = 1))

n_raters <- purrr::map_int(d_subfreq_dupes$data,
                           ncol) %>%
    max(.)

d_subfreq_dupes$data <- d_subfreq_dupes$data %>%
    purrr::map(.,
               ~magrittr::set_colnames(.x,
                                       paste0('rater_',
                                              1:n_raters)))

d_subfreq_dupes <- d_subfreq_dupes$data %>%
    purrr::map(.,
               dplyr::as_tibble) %>%
    purrr::reduce(.,
                  dplyr::bind_rows) %>%
    dplyr::bind_cols(d_subfreq_dupes,
                     .) %>%
    dplyr::select(.,
                  -data) %>%
    dplyr::ungroup(.)

# combine ratings in the two dataframes
d_subfreq <- dplyr::bind_rows(d_subfreq,
                              d_subfreq_dupes)

# get mean and median
d_subfreq$mean <- d_subfreq %>%
    dplyr::select(.,
                  matches('rater')) %>%
    rowMeans(.,
             na.rm = T)

d_subfreq$median <- d_subfreq %>%
    dplyr::select(.,
                  matches('rater')) %>%
    apply(.,
          MARGIN = 1,
          median,
          na.rm = T)

rm(d_subfreq_dupes,
   v_subfreq_dupes,
   n_raters)

# filter out strings not present in reaction time data
d_subfreq <- d_subfreq %>%
    dplyr::filter(.,
                  string %in% d_rt_words$string)
