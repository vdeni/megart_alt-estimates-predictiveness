library(cmdstanr)
library(here)
library(magrittr)
library(dplyr)
library(readr)
library(tidyr)

d <- readr::read_csv(here::here('stats',
                                'reaction-time_fake-data.csv'))

m_rt <- cmdstanr::cmdstan_model(here('stats',
                                     'reaction-time_model.stan'))

summaries <- dplyr::tibble()

for (i in 1:max(d$.iter)) {
    if (i %% 10 == 0) {
        print(paste(paste0(rep('#',
                               30),
                           collapse = ''),
                    'i /',
                    nrow(d),
                    paste0(rep('#',
                               30),
                           collapse = '')))
    }

    d_subset <- dplyr::filter(d,
                              .iter == i)

    .SUBFREQ <- dplyr::select(d_subset,
                              matches('subfreq_\\d+')) %>%
        dplyr::distinct(.) %>%
        {t(.)[, 1]} %>%
        unname(.)

    .IMAGE <- select(d_subset,
                     matches('image_\\d+')) %>%
        dplyr::distinct(.) %>%
        {t(.)[, 1]} %>%
        unname(.)

    datalist <- list('N_OBS' = nrow(d_subset),
                     'N_SUBS' = max(d_subset$.sub_id),
                     'SUBS' = d_subset$.sub_id,
                     'N_WORDS' = max(d_subset$.word_id),
                     'WORDS' = d_subset$.word_id,
                     'RT' = d_subset$rt_rep,
                     'SUBFREQ' = .SUBFREQ,
                     'IMAGE' = .IMAGE)

    .m_rt_samples <- m_rt$sample(data = datalist,
                                 chains = 15,
                                 parallel_chains = 15,
                                 iter_warmup = 1.5e3,
                                 iter_sampling = 2e3)

    .summary <- .m_rt_samples$summary() %>%
        dplyr::filter(.,
                      variable %in% c('c_SUBFREQ',
                                      'c_IMAGE')) %>%
        select(.,
               'variable',
               'mean',
               'q5',
               'q95')

    summaries <- dplyr::bind_rows(summaries,
                                  .summary)
}

readr::write_csv(summaries,
                 here('stats',
                      'reaction-time_fake-data_summaries.csv'))
