library(here)
library(cmdstanr)
library(tidyr)
library(bayesplot)

# load dataframes with estimates
source(here::here('wrangling',
                  '02_prepare-psycholing-data.R'))

# compile model
m_probit <- cmdstanr::cmdstan_model(here::here('stats',
                                               '02_latent-mean_model.stan'))

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

# conduct model checking for subset of words
set.seed(1)

v_subset <- sample(1:max(unique(d_image_long$string_id)),
                   size = 10,
                   replace = F)

d_model_checking <- d_image_long %>%
    dplyr::filter(.,
                  string_id %in% v_subset)

# initialize tibble for storing estimates
estimates <- tibble()

# loop over words, extract estimates
for (i in 1:max(unique(d_image_long$string_id))) {
    .data <- dplyr::filter(d_image_long,
                           string_id == i)

    .m_probit_samples <- m_probit$sample(data = list('K' = 5,
                                                     'N' = length(.data$rating),
                                                     'Y' = .data$rating,
                                                     'c_1' = 1.5,
                                                     'c_4' = 4.5),
                                         chains = 9,
                                         parallel_chains = 9,
                                         iter_warmup = 3e3,
                                         iter_sampling = 4e3,
                                         adapt_delta = .93)

    .out <- .m_probit_samples$summary() %>%
        dplyr::select(.,
                      variable,
                      mean,
                      sd,
                      q5,
                      q95,
                      rhat,
                      ess_bulk,
                      ess_tail) %>%
        dplyr::filter(.,
                      variable == 'mu') %>%
        tidyr::pivot_wider(.,
                           names_from = 'variable',
                           names_glue = '{variable}_{.value}',
                           values_from = mean:ess_tail)

    .out %<>%
        dplyr::mutate(.,
                      'string_id' = i)

    estimates <- bind_rows(estimates,
                           .out)
}
