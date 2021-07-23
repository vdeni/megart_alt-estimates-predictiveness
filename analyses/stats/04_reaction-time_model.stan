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
parameters {
  vector[N_subs] A_sub; // participant-specific parameters
  real mi_A; // mean of participant-specific intercept distribution
  real<lower=0> sigma_A; // standard deviation of p-s intercept distribution

  real<lower=0> sigma_rt; // standard deviation of reaction time distributions

  real B_subfreq; // coefficient for subjective frequency effect
  real B_image; // coefficient for imageability effect

  vector[N_words] C_word; // word-specific parameters
  real mi_C; // mean of word-specific intercept distribution
  real<lower=0> sigma_C; // standard deviation of w-s intercept distribution
}
model {
  vector[N_obs] mi; // location parameter of lognormal distro for each response

  // likelihood
  for (n in 1:N_obs) {
    mi[n] = mi_A +
      A_sub[subs[n]] +
      mi_C +
      C_word[words[n]] +
      B_subfreq * subfreq[n] +
      B_image * image[n];
  }

  rt ~ lognormal(mi, sigma_rt);

  // priors
  sigma_rt ~ exponential(2);

  mi_A ~ normal(6.5, .4);
  sigma_A ~ exponential(1);

  A_sub ~ normal(0, .75);

  B_subfreq ~ normal(-0.5, .7);
  B_image ~ normal(-0.25, .7);

  mi_C ~ normal(0, 3);
  sigma_C ~ exponential(1);

  C_word ~ normal(0, .5);
}
generated quantities {
  array[N_obs] real<lower=0> rt_rep;
  vector[N_obs] mi;

  for (n in 1:N_obs) {
    mi[n] = mi_A +
      A_sub[subs[n]] +
      C_word[words[n]] +
      B_subfreq * subfreq[n] +
      B_image + image[n];
  }

  rt_rep = lognormal_rng(mi, sigma_rt);
}
