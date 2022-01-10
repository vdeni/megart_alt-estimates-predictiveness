data {
  int<lower=2> K; // number of categories

  int<lower=0> N; // number of data points

  real<lower=1, upper=5> c_1;
  real<lower=1, upper=5> c_4;
}
generated quantities {
  array[N] int Y_rep;

  ordered[K - 1] c; // thresholds

  // priors
  real mi = normal_rng(2.5, .25);
  real<lower=0> sigma = exponential_rng(1);

  real<lower=1, upper=5> c_2 = normal_rng(2.5, .25);
  real<lower=1, upper=5> c_3 = normal_rng(3.5, .25);

  // put thresholds in vector for easier calculation
  c[1] = c_1;
  c[2] = c_2;
  c[3] = c_3;
  c[4] = c_4;

  // create vectir fir value probabilities
  vector[K] theta;

  theta[1] = fmax(Phi((c[1] - mi) / sigma),
                  0);

  for (k in 2:(K - 1)) {
    theta[k] = fmax(Phi((c[k] - mi) / sigma) - Phi((c[k - 1] - mi) / sigma),
                    0);
  }

  theta[K] = fmax(1 - Phi((c[K - 1] - mi) / sigma),
                  0);

  for (n in 1:N) {
    Y_rep[n] = categorical_rng(theta);
  }
}
