# import reaction time data, select only words and relevant columns, merge into
# single dataframe
library(dplyr)
library(here)
library(magrittr)
library(readr)

# read first wave data. remove unnecessary columns
d_rt_1 <- readr::read_csv(here::here('data',
                                     'reaction-times',
                                     'cda1012_dat_c_reaction-times_1.csv')) %>%
    dplyr::select(.,
                  id,
                  string,
                  string_type,
                  stimulus_rt,
                  stimulus_acc) %>%
    dplyr::filter(.,
                  string_type == 'word') %>%
    dplyr::select(.,
                  -string_type)

d_rt_2 <- readr::read_csv(here::here('data',
                                     'reaction-times',
                                     'cda1012_dat_c_reaction-times_2.csv')) %>%
    dplyr::select(.,
                  id,
                  string,
                  string_type,
                  stimulus_rt,
                  stimulus_acc) %>%
    dplyr::filter(.,
                  string_type == 'word') %>%
    dplyr::select(.,
                  -string_type)

d_rt <- dplyr::bind_rows(d_rt_1,
                         d_rt_2)

rm(d_rt_1,
   d_rt_2)
