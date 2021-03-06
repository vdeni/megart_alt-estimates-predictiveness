library(here)
library(cmdstanr)
library(tidyr)

.args <- commandArgs(trailingOnly = T)

# load dataframes with estimates
source(here::here('wrangling',
                  'psycholing-data_prepare.R'))

d <- eval(parse(text = .args[3]))

# add string id
d %<>%
    dplyr::mutate(.,
                  string_id = 1:nrow(.))

# transform data to long for analysis
d_long <- d %>%
    tidyr::pivot_longer(.,
                        cols = matches('rater'),
                        names_to = 'rater',
                        values_to = 'rating') %>%
    tidyr::drop_na(.)

# initialize tibble for storing estimates
estimates <- tibble()

# loop over words, extract estimates
for (i in 1:max(unique(d_long$string_id))) {

    print(paste(paste0(rep('#', 30),
                       collapse = ''),
                i,
                paste0(rep('#', 30),
                       collapse = ''),
                collapse = ' '))

    if (i == 1) {
        # compile model and recompile every 10 iterations
        m_probit <-
            cmdstanr::cmdstan_model(here::here('stats',
                                               'latent-mean_model.stan'))
    }
    else if (i %% 10 == 0) {
        m_probit <-
            cmdstanr::cmdstan_model(here::here('stats',
                                               'latent-mean_model.stan'),
                                    force_recompile = T)
    }

    .data <- dplyr::filter(d_long,
                           string_id == i)

    .m_probit_samples <- m_probit$sample(data = list('K' = 5,
                                                     'N' = length(.data$rating),
                                                     'Y' = .data$rating,
                                                     'c_1' = 1.5,
                                                     'c_4' = 4.5),
                                         chains = 24,
                                         parallel_chains = 24,
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
                      variable == 'mi') %>%
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

estimates <- dplyr::select(d,
                           string,
                           string_id) %>%
    dplyr::left_join(estimates,
                     .,
                     by = 'string_id')

readr::write_csv(estimates,
                 here::here('stats',
                            .args[2]))
