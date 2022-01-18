/*
The data is supplied from two different dataframes. One (RT data) contains
individual reaction times to lexical decision stimuli provided by the
participants. The second (word data) contains the subjective frequencies and
imageability ratings for each of the words presented to the participants in the
lexical decision task.
 */
functions {
  // Shifted lognormal distribution function (taken from:
  // https://github.com/Nathaniel-Haines/Reliability_2020/blob/master/Code/Stan/jointSingle_RT_shiftlnorm.stan)
  real shiftlnorm_lpdf(real x, real delta, real mu, real sigma) {
    real log_pr;

    log_pr = (-log((x - delta) * sigma * sqrt(2 * pi())) -
      (log(x - delta) - mu)^2 / (2 * sigma^2));

    return log_pr;
  }

  // for generating posterior predictions
  real shiftlnorm_rng(real delta, real mu, real sigma) {
    return delta + lognormal_rng(mu, sigma);
  }
}
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
  real a_0;

  vector[N_SUBS] z_b_SUBS;
  vector[N_SUBS] mi_b_SUBS; // mean of participant-specific parameter distribution
  real<lower=0> sigma_b_SUBS; // standard deviation of p-s parameter distribution
  vector[N_SUBS] delta; // per-subject shift parameter for shift lognormal

  vector[N_WORDS] c_0; // word-specific intercept

  real c_SUBFREQ; // coefficient for subjective frequency effect
  real c_IMAGE; // coefficient for imageability effect

  real<lower=0> sigma_RT; // standard deviation of reaction time distributions

  vector[N_WORDS] z_c_WORDS;
  real<lower=0> sigma_c_WORDS; // per-word standard deviation
}
transformed parameters {
  vector[N_SUBS] b_SUBS = mi_b_SUBS + z_b_SUBS * sigma_b_SUBS;
}
model {
  vector[N_OBS] mi_obs; // location parameter of lognormal distro for each response
  vector[N_WORDS] mi_word; // location parameter for distro of word components
  vector[N_WORDS] c_WORDS; // word-specific parameters

  for (word in 1:N_WORDS) {
    mi_word[word] = c_0[word] +
      c_SUBFREQ * SUBFREQ[word] +
      c_IMAGE * IMAGE[word];

    c_WORDS[word] = mi_word[word] + z_c_WORDS[word] * sigma_c_WORDS;
  }

  for (obs in 1:N_OBS) {
    mi_obs[obs] = a_0 +
      b_SUBS[SUBS[obs]] +
      c_WORDS[WORDS[obs]];

    // likelihood
    RT[obs] ~ shiftlnorm(delta[SUBS[obs]],
                         mi_obs[obs],
                         sigma_RT);
  }

  // priors
  sigma_RT ~ exponential(3);

  a_0 ~ normal(7.0, .25);

  z_b_SUBS ~ std_normal();
  mi_b_SUBS ~ normal(0, .15);
  sigma_b_SUBS ~ exponential(6);
  delta ~ normal(300, 25);

  c_0 ~ normal(0, .15);

  z_c_WORDS ~ std_normal();

  c_SUBFREQ ~ normal(-0.5, .15);
  c_IMAGE ~ normal(-0.25, .15);

  sigma_c_WORDS ~ exponential(6);
}
generated quantities {
  array[N_OBS] real<lower=0> RT_rep;
  vector[N_WORDS] mi_word;
  vector[N_WORDS] c_WORDS;
  vector[N_OBS] mi_obs;

  for (word in 1:N_WORDS) {
    mi_word[word] = c_0[word] +
      c_SUBFREQ * SUBFREQ[word] +
      c_IMAGE * IMAGE[word];

    c_WORDS[word] = mi_word[word] + z_c_WORDS[word] * sigma_c_WORDS;
  }

  for (obs in 1:N_OBS) {
    mi_obs[obs] = a_0 +
      b_SUBS[SUBS[obs]] +
      c_WORDS[WORDS[obs]];

    RT_rep[obs] = shiftlnorm_rng(delta[SUBS[obs]],
                                 mi_obs[obs],
                                 sigma_RT);
  }

  // calculate log-likelihood
  vector[N_OBS] log_lik;

  for (obs in 1:N_OBS) {
    log_lik[obs] = shiftlnorm_lpdf(RT[obs] | delta[SUBS[obs]],
                                   a_0 + b_SUBS[SUBS[obs]] + c_WORDS[WORDS[obs]],
                                   sigma_RT);
  }
}
