# merge all data for analysis; discard unnecessary columns and remove
# unnecessary objects
library(here)

# source RT data and psycholinguistic mean and median estimates
source(here::here('wrangling',
                  'reatcion-times_merge.R'))

source(here::here('wrangling',
                  'psycholing-data_prepare.R'))

# load latent mean estimates
d_latent_image <-
    readr::read_csv(here::here('stats',
                               'latent-mean_estimates_imageability.csv'))

d_latent_subfreq <- 
    readr::read_csv(here::here('stats',
                               'latent-mean_estimates_subfreq.csv'))

# remove strings whose chains haven't converged according to the Rhat statistic;
# reference value 1.1 used, as per Kruschke: Doing Bayesian Data Analysis (2015,
# p. 181). also remove strings whose bulk ESS is less than 10000
d_latent_image %<>%
    dplyr::filter(.,
                  mu_rhat <= 1.1 & mu_ess_bulk >= 1e4)

d_latent_subfreq %<>%
    dplyr::filter(.,
                  mu_rhat <= 1.1 & mu_ess_bulk >= 1e4)

# combine data
# imageability
d <- dplyr::select(d_image,
                   'image_mean' = mean,
                   'image_median' = median,
                   string) %>%
    dplyr::left_join(d_rt,
                     .,
                     by = 'string')

d <- dplyr::select(d_latent_image,
                   'image_latent_mean' = mu_mean,
                   string) %>%
    dplyr::left_join(d,
                     .,
                     by = 'string')

# subjective frequency
d <- dplyr::select(d_subfreq,
                   'subfreq_mean' = mean,
                   'subfreq_median' = median,
                   string) %>%
    dplyr::left_join(d,
                     .,
                     by = 'string')

d <- dplyr::select(d_latent_subfreq,
                   'subfreq_latent_mean' = mu_mean,
                   string) %>%
    dplyr::left_join(d,
                     .,
                     by = 'string')

# remove rows missing an estimate
d %<>%
    tidyr::drop_na(.,
                   matches('image|subfreq'))

# choose only correct responses
d %<>%
    dplyr::filter(.,
                  stimulus_acc == T)

# add numeric ID variables for participants and words
d %<>%
    dplyr::group_by(.,
                    id) %>%
    tidyr::nest(.) %>%
    tibble::add_column(.,
                       id_numeric = 1:nrow(.),
                       .after = 1) %>%
    tidyr::unnest(.,
                  cols = 'data') %>%
    dplyr::ungroup(.)

d %<>%
    dplyr::group_by(.,
                    string) %>%
    tidyr::nest(.) %>%
    tibble::add_column(.,
                       string_id = 1:nrow(.),
                       .after = 'string') %>%
    tidyr::unnest(.,
                  cols = 'data') %>%
    dplyr::ungroup(.) %>%
    dplyr::select(.,
                  id,
                  id_numeric,
                  string,
                  string_id,
                  dplyr::everything())

# grand-mean center predictors
d %<>%
    dplyr::mutate(.,
                  dplyr::across(.cols = dplyr::matches('^(image|subfreq)'),
                                .fns = ~c(scale(.x,
                                                scale = F))))

# extract word-data into separate dataframe for word-level modeling
d_words <- dplyr::select(d,
                         string,
                         string_id,
                         dplyr::matches('image|subfreq'))

d_words %<>%
    dplyr::distinct(.)

# remove unnecessary objects
rm(d_image,
   d_latent_image,
   d_subfreq,
   d_latent_subfreq,
   d_rt,
   d_rt_words)
