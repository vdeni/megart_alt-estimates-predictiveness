library(here)
library(readr)
library(dplyr)
library(magrittr)
library(ggplot2)

theme_set(theme_minimal())

d_summaries <- readr::read_csv(here::here('stats',
                                          'latent-mean_fake-data_summaries.csv'))

d_fake <- read_csv(here('stats',
                        'latent-mean_fake-data.csv'))

# parameter recovery check
d_fake_mi <- dplyr::select(d_fake,
                           mi,
                           .iter) %>%
    dplyr::distinct(.)

d_summaries %<>%
    dplyr::mutate(.,
                  .iter = 1:nrow(.))

d_plot <- dplyr::left_join(d_summaries,
                           d_fake_mi,
                           by = '.iter')

d_plot$in_interval <- ifelse(d_plot$mi >= d_plot$q5 & d_plot$mi <= d_plot$q95,
                             T,
                             F)

ggplot2::ggplot(d_plot,
                aes(x = mi,
                    y = mean,
                    group = .iter,
                    color = in_interval)) +
    ggplot2::geom_point(size = 3,
                        alpha = .7) +
    ggplot2::geom_errorbar(aes(ymin = q5,
                               ymax = q95),
                           alpha = .7) +
    ggplot2::geom_abline(slope = 1) +
    ggplot2::scale_x_continuous(breaks = 1:5,
                                labels = 1:5,
                                minor_breaks = NULL) +
    ggplot2::scale_y_continuous(breaks = 1:5,
                                labels = 1:5) +
    ggplot2::coord_cartesian(xlim = c(1, 5),
                             ylim = c(1, 5))
