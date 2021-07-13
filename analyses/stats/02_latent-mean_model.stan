data {
  int<lower=2> K; // number of rating categories

  int<lower=0> N; // number of data points

  int<lower=1> S; // number of strings rated

  int<lower=1> string_id[N]; // ID number for each string

  // first and last threshold in probit model; one threshold for each string
  // fixed as per Kruschke (2015, p. 657)
  real<lower=1, upper=5> c_1;
  real<lower=1, upper=5> c_4;

  int<lower=1, upper=K> Y[N]; // data vector, i.e. psycholinguistic ratings
}
parameters {
  // latent normal mean vector; one mu for each string
  vector[S] mu;

  // latent normal standard deviation vector; one sigma for each string
  vector<lower=0>[S] sigma; 

  // vectors for thresholds to be estimated; one threshold for each string
  vector<lower=1, upper=5>[S] c_2;
  vector<lower=1, upper=5>[S] c_3;
}
transformed parameters {
  array[S] ordered[K - 1] c; // thresholds

  for (s in 1:S) {
    c[s, 1] = c_1;
    c[s, 2] = c_2[s];
    c[s, 3] = c_3[s];
    c[s, 4] = c_4;
  }
}
model {
  // priors
  mu ~ normal(2.5, .25);
  sigma ~ exponential(1);

  for (s in 1:S) {
    // add priors for other thresholds
    c_2[s] ~ normal(2.5, .25);
    c_3[s] ~ normal(3.5, .25);
  }

  // array of vectors with probabilities of observing each rating;
  // one vector for each string
  array[S] vector[K] theta;

  for (n in 1:N) {
    // calculate probabilites of observing lowest rating, i.e. 1
    theta[string_id[N], 1] = fmax(Phi((c[string_id[N], 1] - mu[string_id[N]]) /
                                      sigma[string_id[N]]),
                                  0);

    // calculate probabilites for ratings [2, 4]
    for (k in 2:(K - 1)) {
      theta[string_id[N], k] = fmax(Phi((c[string_id[N], k] - mu[string_id[N]]) /
                                        sigma[string_id[N]]) -
                                    Phi((c[string_id[N], k - 1] - mu[string_id[N]]) /
                                        sigma[string_id[N]]),
                                    0);
    }

    // calculate probability for highest rating, i.e. 5
    theta[string_id[N], K] = fmax(1 - Phi((c[string_id[N], K - 1] -
                                          mu[string_id[N]]) / sigma[string_id[N]]),
                                  0);

    // likelihood
    Y[n] ~ categorical(theta[string_id[N]]);
  }
}
