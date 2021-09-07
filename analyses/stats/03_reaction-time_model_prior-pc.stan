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
  vector[N_SUBS] z_B_SUBS;

  real A_0 = normal_rng(6.5, .25);

  real mi_B = normal_rng(0, .15);
  real<lower=0> sigma_B = exponential_rng(6);

  vector[N_SUBS] B_SUBS;

  for (sub in 1:N_SUBS) {
    z_B_SUBS[sub] = std_normal_rng();
    B_SUBS[sub] = mi_B + z_B_SUBS[sub] * sigma_B;
  }

  vector[N_WORDS] C_0;

  for (word in 1:N_WORDS) {
    C_0[word] = normal_rng(0, .15);
  }

  real C_SUBFREQ = normal_rng(-0.5, .15);
  real C_IMAGE = normal_rng(-.25, .15);

  vector[N_WORDS] C_WORDS;
  real sigma_C_WORDS = exponential_rng(6);

  for (word in 1:N_WORDS) {
    real mi_word = C_0[word] +
      C_SUBFREQ * SUBFREQ[word] +
      C_IMAGE * IMAGE[word];

    C_WORDS[word] = normal_rng(mi_word, sigma_C_WORDS);
  }

  real<lower=0> sigma_RT = exponential_rng(3);

  for (obs in 1:N_OBS) {
    mi_obs[obs] = A_0 +
      B_SUBS[SUBS[obs]] +
      C_WORDS[WORDS[obs]];
  }

  RT_rep = lognormal_rng(mi_obs, sigma_RT);
}
