library(cmdstanr)
library(here)
library(magrittr)
library(dplyr)
library(readr)

d <- readr::read_csv(here::here('stats',
                                'latent-mean_fake-data.csv'))

m_probit <- cmdstanr::cmdstan_model(here::here('stats',
                                               'latent-mean_model.stan'))

summaries <- dplyr::tibble()

for (i in 1:max(unique(d$.iter))) {
    d_subset <- filter(d,
                       .iter == i)

    datlist <- list('K' = 5,
                    'N' = length(d_subset$rating),
                    'Y' = d_subset$rating,
                    'c_1' = 1.5,
                    'c_4' = 4.5)

    .m_probit_samples <- m_probit$sample(data = datlist,
                                         chains = 15,
                                         parallel_chains = 15,
                                         iter_warmup = 2e3,
                                         iter_sampling = 1.2e3)

    .summary <- .m_probit_samples$summary() %>%
        dplyr::filter(.,
                      variable == 'mi') %>%
        dplyr::select(.,
                      'mean',
                      'q5',
                      'q95')

    summaries <- dplyr::bind_rows(summaries,
                                  .summary)
}

readr::write_csv(summaries,
                 here('stats',
                      'latent-mean_fake-data_summaries.csv'))
