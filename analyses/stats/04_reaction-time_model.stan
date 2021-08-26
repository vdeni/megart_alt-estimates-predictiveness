/*
The data is supplied from two different dataframes. One (RT data) contains
individual reaction times to lexical decision stimuli provided by the
participants. The second (word data) contains the subjective frequencies and
imageability ratings for each of the words presented to the participants in the
lexical decision task.
 */

data {
  // ID variables
  int<lower=1> N_OBS; // number of reaction times in RT data

  int<lower=1> N_SUBS; // number of participants in RT data
  array[N_OBS] int<lower=1> SUBS; // array indexing participants in RT data

  int<lower=1> N_WORDS; // number of words in RT and word data
  array[N_OBS] int<lower=1> WORDS; // array indexing words in RT data

  // criterion
  vector<lower=0>[N_OBS] RT; // reaction times in the RT data

  // predictors
  vector[N_WORDS] SUBFREQ; // subjective frequency estimates in the word data

  vector[N_WORDS] IMAGE; // imageability estimates in the word data
}
parameters {
  vector[N_SUBS] A_SUBS; // participant-specific parameters
  real mi_A; // mean of participant-specific parameter distribution
  real<lower=0> sigma_A; // standard deviation of p-s parameter distribution

  vector[N_WORDS] B_0; // word-specific intercept
  real<lower=0> sigma_B_0; // standard deviation of w-s intercept distribution

  real B_SUBFREQ; // coefficient for subjective frequency effect
  real B_IMAGE; // coefficient for imageability effect

  real<lower=0> sigma_RT; // standard deviation of reaction time distributions

  vector[N_WORDS] B_WORDS; // per-word parameter TODO: better description
  real<lower=0> sigma_B_WORDS; // per-word standard deviation
}
model {
  vector[N_OBS] mi_obs; // location parameter of lognormal distro for each response
  vector[N_WORDS] mi_word; // location parameter for distro of word components

  for (word in 1:N_WORDS) {
    mi_word[word] = B_0[word] +
      B_SUBFREQ * SUBFREQ[word] +
      B_IMAGE * IMAGE[word];
  }

  for (obs in 1:N_OBS) {
    mi_obs[obs] = mi_A +
      A_SUBS[SUBS[obs]] +
      B_WORDS[WORDS[obs]];
  }

  // likelihood
  RT ~ lognormal(mi_obs, sigma_RT);

  // priors
  sigma_RT ~ exponential(2);

  mi_A ~ normal(6.5, .4);
  sigma_A ~ exponential(1);

  A_SUBS ~ normal(0, .75);

  B_0 ~ normal(0, .5);
  sigma_B_0 ~ exponential(1);

  B_SUBFREQ ~ normal(-0.5, .7);
  B_IMAGE ~ normal(-0.25, .7);

  B_WORDS ~ normal(mi_word, sigma_B_WORDS);
  sigma_B_WORDS ~ exponential(1);
}
// generated quantities {
//   array[N_obs] real<lower=0> rt_rep;
//   vector[N_obs] mi;
// 
//   for (n in 1:N_obs) {
//     mi[n] = mi_A +
//       A_sub[subs[n]] +
//       C_word[words[n]] +
//       B_subfreq * subfreq[n] +
//       B_image + image[n];
//   }
// 
//   rt_rep = lognormal_rng(mi, sigma_rt);
// }
