library(data.table)
library(here)
library(cmdstanr)

data.table::setDTthreads(parallel::detectCores() / 2)

.args <- commandArgs(trailingOnly = T)

.outfile <- here::here('stats',
                       paste0('model-out-data_',
                              .args[2]),
                       paste0('summary_',
                              .args[2],
                              '.csv'))

.model <- readRDS(here::here('stats',
                             paste0('model-out-data_',
                                    .args[2]),
                             paste0('m_',
                                    .args[2],
                                    '.RData')))

.model$runset$.__enclos_env__$private$output_files_ <-
    list.files(here::here('stats',
                          paste0('model-out-data_',
                                 .args[2])),
               pattern = '04.*csv$',
               full.names = T)

cat('\n\n',
    '>>>>>>>>>>',
    'Processing variable:',
    as.character(.args[3]),
    '\n\n')

.summary <- .model$summary(variables = as.character(.args[3]))

if (file.exists(.outfile)) {

    cat('\n\nAppending to file...\n\n')

    data.table::fwrite(.summary,
                       file = .outfile,
                       append = T,
                       col.names = F)
} else {
    cat('\n\nWriting to file...\n\n')

    data.table::fwrite(.summary,
                       .outfile)
}
