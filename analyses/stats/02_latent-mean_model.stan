data {
  int<lower=2> K; // number of categories

  int<lower=0> N; // number of data points

  int<lower=1, upper=K> Y[N]; // data vector, i.e. psycholinguistic ratings

  real<lower=1, upper=5> c_1;
  real<lower=1, upper=5> c_4;
}
parameters {
  real mu; // latent normal mean
  real<lower=0> sigma; // latent normal standard deviation

  real<lower=1, upper=5> c_2;
  real<lower=1, upper=5> c_3;
}
transformed parameters {
  ordered[K - 1] c; // thresholds

  // fix first and last threshold, as per Kruschke (2015; p. 675)
  c[1] = c_1;
  c[2] = c_2;
  c[3] = c_3;
  c[4] = c_4;
}
model {
  vector[K] theta; // vector with probabilities of observing each rating

  // priors
  mu ~ normal(2.5, .25);
  sigma ~ exponential(1);

  // add priors for other thresholds
  c_2 ~ normal(2.5, .25);
  c_3 ~ normal(3.5, .25);

  for (n in 1:N) {
    // calculate probabilites of observing lowest rating, i.e. 1
    theta[1] = fmax(Phi((c[1] - mu) / sigma),
                    0);

    // calculate probabilites for ratings [2, 4]
    for (k in 2:(K - 1)) {
      theta[k] = fmax(Phi((c[k] - mu) / sigma) - Phi((c[k - 1] - mu) / sigma),
                      0);
    }

    // calculate probability for highest rating, i.e. 5
    theta[K] = fmax(1 - Phi((c[K - 1] - mu) / sigma),
                    0);

    // likelihood
    Y[n] ~ categorical(theta);
  }
}
