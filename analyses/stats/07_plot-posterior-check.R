library(magrittr)
library(here)
library(data.table)
library(tidyr)
library(dplyr)
library(ggplot2)
library(viridis)

setwd(here::here())

renv::activate()

.args <- commandArgs(trailingOnly = T)

source(here::here('wrangling',
                  '03_prepare-analysis-data.R'))

data.table::setDTthreads(parallel::detectCores() / 2)

d_rt_rep_mean <- data.table::fread(here::here('stats',
                                              paste0('model-out-data_',
                                                     .args[2]),
                                              paste0('d_rt-rep-subsamp_',
                                                     .args[2],
                                                     '.csv')))

d_rt_rep_mean$iter <- 1:nrow(d_rt_rep_mean)

d_rt_rep_mean %<>%
    tidyr::pivot_longer(.,
                        cols = matches('RT_rep'),
                        names_to = 'rt_id',
                        names_pattern = 'RT_rep\\.(\\d+)',
                        names_transform = list('rt_id' = as.integer),
                        values_to = 'rt_rep')

.viridis_begin <- .4

.plot_titles <- c('mean' = 'Aritmetička sredina',
                  'median' = 'Medijan',
                  'latent-mean' = 'Latentna aritmetička sredina')

p_prc <- ggplot2::ggplot(d_rt_rep_mean,
                         aes(x = rt_rep,
                             group = iter)) +
    geom_density(data = d,
                 mapping = aes(x = stimulus_rt),
                 inherit.aes = F,
                 size = 1,
                 fill = viridis::viridis(1,
                                         begin = .viridis_begin),
                 alpha = .3,
                 n = 8e3,
                 color = viridis::viridis(1,
                                          begin = .viridis_begin)) +
    geom_density(color = 'black',
                 size = .03,
                 n = 8e3) +
    coord_cartesian(xlim = c(0, 5e3)) +
    theme_minimal() +
    theme(panel.grid.major.y = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.x = element_line(linetype = 'dashed',
                                            color = '#cac7c7'),
          panel.grid.minor.x = element_line(linetype = 'dashed',
                                            color = '#cac7c7'),
          axis.text.y = element_blank()) +
    labs(x = 'Vrijeme reakcije u milisekundama',
         y = '',
         title = .plot_titles[.args[2]])

ggplot2::ggsave(p_prc,
                filename = here::here('stats',
                                      paste0('model-out-data_',
                                             .args[2]),
                                      paste0('p_prc_',
                                             .args[2],
                                             '.pdf')),
                device = 'pdf')
