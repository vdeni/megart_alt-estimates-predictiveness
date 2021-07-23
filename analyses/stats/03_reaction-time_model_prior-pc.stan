data {
  // ID variables
  int<lower=1> N_obs; /* number of observations in dataset, i.e. number of
                      reaction times */

  int<lower=1> N_subs; // number of participants in dataset
  array[N_obs] int<lower=1> subs; // array indexing participants

  int<lower=1> N_words; // number of words in dataset
  array[N_obs] int<lower=1> words; // array indexing words

  // criterion
  vector<lower=0>[N_obs] rt; // reaction times vector

  // predictors
  vector[N_obs] subfreq; // words' estimated subjective frequencies

  vector[N_obs] image; // words' estimated imageabilities
}
generated quantities {
  array[N_obs] real<lower=0> rt_rep;
  vector[N_obs] mi;

  real mi_A = normal_rng(6.5, .4);
  real<lower=0> sigma_A = exponential_rng(1);
  vector[N_subs] A_sub;

  for (n in 1:N_subs) {
    A_sub[n] = normal_rng(0, .75);
  }

  real B_subfreq = normal_rng(-0.5, .7);
  real B_image = normal_rng(-.25, .7);

  real mi_C = normal_rng(0, 3);
  real<lower=0> sigma_C = exponential_rng(1);
  vector[N_words] C_word;

  for (n in 1:N_words) {
    C_word[n] = normal_rng(0, .50);
  }

  vector[N_words] C;

  for (n in 1:N_words) {
    C[n] = mi_C +
      C_word[n] +
      B_subfreq * subfreq[words[n]] +
      B_image * image[words[n]];
  }

  real<lower=0> sigma_rt = exponential_rng(2);

  for (n in 1:N_obs) {
    mi[n] = mi_A +
      A_sub[subs[n]] +
      C[words[n]];
  }

  rt_rep = lognormal_rng(mi, sigma_rt);
}
