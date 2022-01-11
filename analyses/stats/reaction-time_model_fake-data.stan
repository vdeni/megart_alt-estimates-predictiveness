data {
  // ID variables
  int<lower=1> N_SUBS; // number of participants in RT data
  int<lower=1> N_WORDS; // number of words in RT and word data

  array[N_SUBS * N_WORDS] int<lower=1> SUBS; // participant-id vector
  array[N_SUBS * N_WORDS] int<lower=1> WORDS; // word-id vector
}
generated quantities {
  // create array for simulated reaction times
  array[N_SUBS * N_WORDS] real<lower=0> RT_rep;

  // vector of participant-specific means and z-values
  vector[N_SUBS * N_WORDS] mi_obs;
  vector[N_SUBS] z_B_SUBS;

  // intercept
  real A_0 = normal_rng(6.5, .25);

  // participant-specific coefficients
  real mi_B = normal_rng(0, .15);

  // standard deviation of participant-specific coefficient distribution
  real<lower=0> sigma_B = exponential_rng(6);

  // vector for holding participant-specific coefficients
  vector[N_SUBS] B_SUBS;

  for (sub in 1:N_SUBS) {
    z_B_SUBS[sub] = std_normal_rng();
    B_SUBS[sub] = mi_B + z_B_SUBS[sub] * sigma_B;
  }

  // create variables for holding word features
  vector[N_WORDS] SUBFREQ; // subjective frequency
  vector[N_WORDS] IMAGE; // imageability estimates

  // grand mean for word-level data
  vector[N_WORDS] C_0;

  // probability vector for generating SUBFREQ and IMAGE values
  vector[5] theta = [.2, .2, .2, .2, .2]';

  for (word in 1:N_WORDS) {
    C_0[word] = normal_rng(0, .15);
    SUBFREQ[word] = categorical_rng(theta);
    IMAGE[word] = categorical_rng(theta);
  }

  // draw coefficients for subjective frequency and imageability
  real C_SUBFREQ = normal_rng(-0.5, .15);
  real C_IMAGE = normal_rng(-.25, .15);

  // vector for holding word data
  vector[N_WORDS] C_WORDS;

  // distribution of word-level values
  real sigma_C_WORDS = exponential_rng(6);

  for (word in 1:N_WORDS) {
    real mi_word = C_0[word] +
      C_SUBFREQ * SUBFREQ[word] +
      C_IMAGE * IMAGE[word];

    C_WORDS[word] = normal_rng(mi_word, sigma_C_WORDS);
  }

  // reaction time distribution sd
  real<lower=0> sigma_RT = exponential_rng(3);

  for (obs in 1:(N_SUBS * N_WORDS)) {
    mi_obs[obs] = A_0 +
      B_SUBS[SUBS[obs]] +
      C_WORDS[WORDS[obs]];
  }

  RT_rep = lognormal_rng(mi_obs, sigma_RT);
}
