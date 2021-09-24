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
                       paste0('rt-rep_',
                              .args[3],
                              '.csv'))

.rt_rep_cols <- readLines('07_rt-rep-cols.txt')

cat(paste0('===== Reading: ',
           .infile,
           ' =====',
           '\n'))

.d <- data.table::fread(file = .infile,
                        verbose = F,
                        select = .rt_rep_cols)

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
