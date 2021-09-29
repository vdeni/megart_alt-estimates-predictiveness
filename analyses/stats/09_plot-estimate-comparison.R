library(here)
library(ggplot2)
library(magrittr)
library(dplyr)
library(tidyr)
library(viridis)

.plot_width <- 12
.viridis_begin <- .4

source(here::here('wrangling',
                  '03_prepare-analysis-data.R'))

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
    geom_line(size = .05,
              color = viridis::viridis(1,
                                      begin = .viridis_begin),
              linetype = 'dotted') +
    geom_point(stat = 'identity',
               fill = viridis::viridis(1,
                                       begin = .viridis_begin),
               color = 'black',
               alpha = .3,
               stroke = .3,
               size = 3,
               shape = 21) +
    facet_wrap(facets = vars(variable),
               nrow = 2,
               ncol = 1,
               labeller = as_labeller(c('image' = 'Predočivost',
                                        'subfreq' = 'Subjektivna čestina'))) +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          text = element_text(family = 'DejaVu Sans')) +
    labs(x = 'Mjera',
         y = 'Standardizirani iznos procjene') +
    scale_x_discrete(labels = c('latent_mean' = 'Latentna aritmetička sredina',
                                'mean' = 'Aritmetička sredina',
                                'median' = 'Medijan'))
    
ggplot2::ggsave(filename = here::here('stats',
                                      'p_estimate-comparison.png'),
                device = 'png',
                bg = '#FFFFFF',
                width = .plot_width,
                height = .plot_width * 9 / 16)
