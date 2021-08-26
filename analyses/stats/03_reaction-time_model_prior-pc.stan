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
generated quantities {
  array[N_OBS] real<lower=0> RT_rep;
  vector[N_OBS] mi_obs;

  real mi_A = normal_rng(6.5, .4);
  real<lower=0> sigma_A = exponential_rng(1);

  vector[N_SUBS] A_SUBS;

  for (sub in 1:N_SUBS) {
    A_SUBS[sub] = normal_rng(mi_A, sigma_A);
  }

  vector[N_WORDS] B_0;

  for (word in 1:N_WORDS) {
    B_0[word] = normal_rng(0, .5);
  }

  real B_SUBFREQ = normal_rng(-0.5, .7);
  real B_IMAGE = normal_rng(-.25, .7);

  vector[N_WORDS] B_WORDS;
  real sigma_B_WORDS = exponential_rng(1);

  for (word in 1:N_WORDS) {
    real mi_word = B_0[word] +
      B_SUBFREQ * SUBFREQ[word] +
      B_IMAGE * IMAGE[word];

    B_WORDS[word] = normal_rng(mi_word, sigma_B_WORDS);
  }

  real<lower=0> sigma_RT = exponential_rng(2);

  for (obs in 1:N_OBS) {
    mi_obs[obs] = A_SUBS[SUBS[obs]] +
      B_WORDS[WORDS[obs]];
  }

  RT_rep = lognormal_rng(mi_obs, sigma_RT);
}
