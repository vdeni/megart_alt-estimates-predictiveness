library(here)
library(dplyr)
library(tidyr)
library(readr)
library(magrittr)
library(ggplot2)

d <- readr::read_csv(here::here('stats',
                                'reaction-time_prior-pc_data.csv'))

d_plot <- tidyr::pivot_longer(d,
                              cols = matches('rt_rep'),
                              names_pattern = '(rt_rep)_(\\d+)',
                              names_to = c('.value',
                                           'observation'))

# plot rt_rep
ggplot2::ggplot(d_plot,
                aes(x = rt_rep,
                    group = iteration)) +
    ggplot2::geom_density(n = 1e4,
                          size = .1) +
    ggplot2::coord_cartesian(xlim = c(0, 3e3))

# plot median rts
d_plot %>%
    dplyr::group_by(.,
                    iteration) %>%
    dplyr::summarise(.,
                     med = median(rt_rep)) %>%
    ggplot(aes(x = med)) +
    ggplot2::geom_histogram(color = 'white') +
    coord_cartesian(xlim = c(0, 5e3))
