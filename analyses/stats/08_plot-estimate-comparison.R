library(here)
library(ggplot2)
library(magrittr)
library(dplyr)
library(tidyr)
library(viridis)

source(here::here('wrangling',
                  '03_prepare-analysis-data.R'))

.viridis_begin <- .4

d_words %>%
    tidyr::pivot_longer(.,
                        cols = matches('image|subfreq'),
                        names_to = c('variable',
                                     'measure'),
                        names_pattern = '(image|subfreq)_(.*)',
                        values_to = 'estimate') %>%
    ggplot2::ggplot(.,
                    aes(x = measure,
                        y = estimate,
                        group = string_id)) +
    geom_point(stat = 'identity',
               color = viridis::viridis(1,
                                       begin = .viridis_begin)) +
    geom_line(size = .03,
              color = viridis::viridis(1,
                                      begin = .viridis_begin)) +
    facet_wrap(facets = vars(variable),
               nrow = 2,
               ncol = 1,
               labeller = as_labeller(c('image' = 'Predočivost',
                                        'subfreq' = 'Subjektivna čestina'))) +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          text = element_text(family = 'Latin Modern Roman')) +
    labs(x = 'Mjera',
         y = 'Standardizirani iznos procjene') +
    scale_x_discrete(labels = c('latent_mean' = 'Latentna aritmetička sredina',
                                'mean' = 'Aritmetička sredina',
                                'median' = 'Medijan'))

.width <- 12
    
ggplot2::ggsave(filename = here::here('stats',
                                      'p_estimate-comparison.png'),
                device = 'png',
                bg = '#FFFFFF',
                width = .width,
                height = .width * 9 / 16)
