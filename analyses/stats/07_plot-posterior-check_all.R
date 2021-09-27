library(magrittr)
library(here)
library(data.table)
library(tidyr)
library(dplyr)
library(ggplot2)
library(viridis)
setwd('..');renv::activate()

source(here::here('wrangling',
                  '03_prepare-analysis-data.R'))

data.table::setDTthreads(parallel::detectCores() / 2)

d_rt_rep_mean <- data.table::fread(here::here('stats',
                                              'model-out-data_mean',
                                              'd_rt-rep-subsamp_mean.csv'))

d_rt_rep_mean$iter <- 1:nrow(d_rt_rep_mean)

d_rt_rep_mean %<>%
    tidyr::pivot_longer(.,
                        cols = matches('RT_rep'),
                        names_to = 'rt_id',
                        names_pattern = 'RT_rep\\.(\\d+)',
                        names_transform = list('rt_id' = as.integer),
                        values_to = 'rt_rep')

ggplot2::ggplot(d_rt_rep_mean,
                aes(x = rt_rep,
                    group = iter)) +
    geom_density(color = 'black',
                 size = .1,
                 n = 3e3,
                 alpha = 1) +
    geom_density(data = d,
                 mapping = aes(x = stimulus_rt),
                 inherit.aes = F,
                 n = 3e3,
                 color = viridis::viridis(1,
                                          begin = .5)) +
    coord_cartesian(xlim = c(0, 5e3))

ggsave(filename = '/tmp/p.jpg', device = 'jpg')
