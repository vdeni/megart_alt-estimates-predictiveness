library(here)
library(readr)
library(dplyr)
library(tidyr)
library(magrittr)
library(ggplot2)

theme_set(theme_minimal())

d_summaries <- readr::read_csv(here::here('stats',
                                          'reaction-time_fake-data_summaries.csv'))

d_fake <- read_csv(here('stats',
                        'reaction-time_fake-data.csv'))

# parameter recovery check
d_fake_params <- dplyr::select(d_fake,
                               c_subfreq,
                               c_image,
                               .iter) %>%
    dplyr::distinct(.) %>%
    tidyr::pivot_longer(.,
                        cols = matches('c_'),
                        names_to = 'variable',
                        values_to = 'value')

d_summaries %<>%
    dplyr::mutate(.,
                  dplyr::across('variable',
                                tolower))

d_plot <- dplyr::left_join(d_summaries,
                           d_fake_params,
                           by = c('.iter',
                                  'variable'))

d_plot$in_interval <- ifelse(d_plot$value >= d_plot$q5 &
                                d_plot$value <= d_plot$q95,
                             T,
                             F)

ggplot2::ggplot(d_plot,
                aes(x = value,
                    y = mean,
                    color = in_interval)) +
    ggplot2::geom_point(size = 3,
                        alpha = .7) +
    ggplot2::geom_errorbar(aes(ymin = q5,
                               ymax = q95),
                           alpha = .7) +
    ggplot2::geom_abline(slope = 1) +
    ggplot2::facet_wrap('variable') +
    ggplot2::coord_cartesian(xlim = c(-1, .5))
