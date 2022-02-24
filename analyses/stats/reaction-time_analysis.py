import os

import pandas
import cmdstanpy

stanfile = os.path.join('stats',
                        'reaction-time_model.stan')

d_subs = pandas.read_csv(os.path.join('stats',
                                      'd_subs.csv'))

d_words = pandas.read_csv(os.path.join('stats',
                                       'd_words.csv'))

m_rt = cmdstanpy.CmdStanModel(stan_file=stanfile,
                              cpp_options={'STAN_THREADS': 'true'})

stan_data = {'N_OBS': d_subs.shape[0],
             'N_SUBS': max(d_subs.id_numeric),
             'SUBS': d_subs.id_numeric.values,
             'N_WORDS': max(d_subs.string_id),
             'WORDS': d_subs.string_id.values,
             'RT': d_subs.stimulus_rt.values,
             'SUBFREQ': d_words.subfreq_median.values,
             'IMAGE': d_words.image_median}

d_samples = m_rt.sample(data=stan_data,
                        chains=24,
                        parallel_chains=24,
                        iter_warmup=1.5e3,
                        iter_sampling=.25e3)
