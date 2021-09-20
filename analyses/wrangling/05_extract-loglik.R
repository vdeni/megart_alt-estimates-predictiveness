library(data.table)
library(here)

data.table::setDTthreads(parallel::detectCores() / 2)

.args <- commandArgs(trailingOnly = T)

.infile <- here::here('stats',
                      paste0('model-out-data_',
                              .args[3]),
                      'tmp',
                      .args[2])

.outfile <- here::here('stats',
                       paste0('model-out-data_',
                              .args[3]),
                       paste0('log-lik_',
                              .args[3],
                              '.csv'))

.ll_cols <- readLines('05_ll-cols.txt')

cat(paste0('===== Reading: ',
           .infile,
           ' =====',
           '\n'))

.d <- data.table::fread(file = .infile,
                        verbose = F,
                        select = .ll_cols)

if (file.exists(.outfile)) {

    cat(paste0('===== Appending: ',
               .infile,
               ' =====',
               '\n'))

    data.table::fwrite(.d,
                       file = .outfile,
                       append = T,
                       col.names = F)
} else {
    cat(paste0('===== Processing: ',
               .infile,
               ' =====',
               '\n'))

    data.table::fwrite(.d,
                       .outfile)
}
