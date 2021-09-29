library(here)
library(ggplot2)
library(ggpubr)

v_plots <- list.dirs(here::here('stats')) %>%
    grep(x = .,
         pattern = 'model',
         value = T) %>%
    list.files(path = .,
               pattern = 'p_prc.*RData',
               full.names = T)

l_plots <- lapply(v_plots,
                  readRDS)

ggpubr::ggarrange(plotlist = l_plots,
                  nrow = 3,
                  ncol = 1)
