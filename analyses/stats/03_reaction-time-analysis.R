# train and compare three different models aimed at prediciting reaction times
# of correct responses on a lexical decision taks, based on the ratings of
# subjective frequencies and imageability

# source analysis data
source(here::here('wrangling',
                  '03_prepare-analysis-data.R'))

library(here)
library(dplyr)
library(magrittr)
library(ggplot2)
library(cmdstanr)
library(bayesplot)

# compile stan model
m_rt_model <- cmdstanr::cmdstan_model(here::here('stats',
                                                 '03_reaction-time_model.stan'))

# mean of ratings
