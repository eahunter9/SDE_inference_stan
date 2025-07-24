#include ode_eulerm_stochastic.stan
data {
 int<lower = 1> n_obs;
 int<lower = 1> n_params;
 int<lower = 1> n_difeq;
 int<lower = 1> inv_DT;
 array[n_obs] int St;
 real t0;
 array[n_obs * inv_DT] int ts;
 real tstep;
 array[n_obs -1] int int_tstep;
 array [2] vector[n_obs * inv_DT] noise;
}
parameters {
  real<lower = 0.001, upper = 0.5> beta;
  real<lower = 0.001, upper =0.5> rho;
  real <lower = 0.001, upper = 0.1> gamma;
  real <lower = 0.001, upper = 0.1> epsilon;
  real <lower = 0.0001, upper = 0.1> sigma1;
  real <lower = 0.0001, upper = 0.1> sigma2;

}
transformed parameters{
  array [n_obs * inv_DT] vector [n_difeq] o; // Output from the ODE solver
  array[n_obs] real x;
  vector[n_difeq] x0;
  array[n_params] real params;
  x0[1] = 0.902400;
  x0[2] = 0.208680;

  params[1] = beta;
  params[2] = gamma;
  params[3] = epsilon;
  params[4] = sigma1;
  params[5] = sigma2;
  params[6] = rho;



  o = sde_euler(x0, ts,  params, tstep, inv_DT,noise );
   x[1] =  o[1, 1];
  for (i in int_tstep) {
    int j =  i * 1 / inv_DT + 1;
    x[j] = o[i, 1] + 1e-5;
  }
}

model {
  beta  ~ lognormal(0, 1);
  rho  ~ lognormal(0, 1);
  gamma  ~ lognormal(0, 1);
  epsilon  ~ lognormal(0, 1);
  sigma1  ~ lognormal(0, 1);
  sigma2  ~ lognormal(0, 1);

  St ~ poisson(x);
}
generated quantities {
  real log_lik;
 log_lik = poisson_lpmf(St | x);
}
