library(here)
library(ggplot2)
library(ggpubr)

.plot_width <- 12

v_plots <- list.dirs(here::here('stats')) %>%
    grep(x = .,
         pattern = 'model',
         value = T) %>%
    list.files(path = .,
               pattern = 'p_prc.*RData',
               full.names = T)

l_plots <- lapply(v_plots,
                  readRDS)

l_plots[[1]] <- l_plots[[1]] +
    labs(x = '')

l_plots[[2]] <- l_plots[[2]] +
    labs(x = '')

.p <- ggpubr::ggarrange(plotlist = l_plots,
                        nrow = 3,
                        ncol = 1)

ggplot2::ggsave(plot = .p,
                filename = here::here('stats',
                                      'p_prc_comparison.png'),
                device = 'png',
                bg = '#FFFFFF',
                width = .plot_width,
                height = .plot_width * 9 / 16)
