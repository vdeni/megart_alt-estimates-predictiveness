library(here)
library(cmdstanr)
library(tidyr)
library(bayesplot)
library(stringr)
library(ggplot2)

# load dataframes with estimates
source(here::here('wrangling',
                  '02_prepare-psycholing-data.R'))

# compile model
m_probit <- cmdstanr::cmdstan_model(here::here('stats',
                                               '01_latent-mean_model.stan'))

##### imageability #####
# add string id
d_image %<>%
    dplyr::mutate(.,
                  string_id = 1:nrow(.))

# transform data to long for analysis
d_image_long <- d_image %>%
    tidyr::pivot_longer(.,
                        cols = matches('rater'),
                        names_to = 'rater',
                        values_to = 'rating') %>%
    tidyr::drop_na(.)

# subset words
set.seed(1)

v_subset <- sample(1:max(unique(d_image_long$string_id)),
                   size = 5,
                   replace = F)

# fit model to chosen words
.data <- dplyr::filter(d_image_long,
                       string_id == v_subset[1])

.m_probit_samples <- m_probit$sample(data = list('K' = 5,
                                                 'N' = length(.data$rating),
                                                 'Y' = .data$rating,
                                                 'c_1' = 1.5,
                                                 'c_4' = 4.5),
                                     chains = 9,
                                     parallel_chains = 9,
                                     iter_warmup = 3e3,
                                     iter_sampling = 4e3,
                                     adapt_delta = .90)

# wrangling draws from model output
.draws <- .m_probit_samples$draws()

d_yrep <- .draws[, , stringr::str_subset(dimnames(.draws)$variable,
                                         'Y_rep')] %>%
    dplyr::as_tibble(.) %>%
    janitor::clean_names(.)

colnames(d_yrep) %<>%
    stringr::str_replace(.,
                         '^x',
                         'chain')

d_yrep %<>%
    dplyr::mutate(.,
                  .iteration = 1:nrow(.)) %>%
    tidyr::pivot_longer(.,
                        cols = matches('chain'),
                        names_pattern = 'chain(\\d)_y_rep_(\\d+)',
                        names_to = c('chain', 'yrep'),
                        values_to = 'rating')

# plot posterior predictions
ggplot(.data,
       mapping = aes(x = rating)) +
    geom_bar() +
    geom_point(inherit.aes = F,
              data = dplyr::filter(d_yrep,
                                   .iteration %in%
                                       sample(1:max(unique(d_yrep$.iteration)),
                                              replace = F,
                                              size = 150)),
              mapping = aes(x = rating,
                            group = interaction(.iteration, chain)),
              stat = 'count',
              size = 3.00,
              alpha = .10,
              position = position_jitter(width = .20,
                                         height = 0))
