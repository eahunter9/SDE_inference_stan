#include ode_eulerm_stochastic.stan
data {
 int<lower = 1> n_obs;
 int<lower = 1> n_params;
 int<lower = 1> n_difeq;
 int<lower = 1> inv_DT;
 array[n_obs] int Cases;
 real t0;
 array[n_obs * inv_DT] int ts;
 real tstep;
 array[n_obs -1] int int_tstep;
 array[3] vector[n_obs * inv_DT] noise;
}
parameters {
  real<lower = 0.1, upper = 1> gamma_parameter;
  real<lower = 1, upper =5> beta_parameter;
  real<lower = 0.1, upper = 1> sigma_parameter;
  //real <lower = 0> inv_phi;
}
transformed parameters{
  array [n_obs * inv_DT] vector [n_difeq] o; // Output from the ODE solver
  array[n_obs] real x;
  vector[n_difeq] x0;
  array[n_params] real params;
// real phi;
// phi = 1 / inv_phi;
  x0[1] = 10000 ;
  x0[2] = 1;
  x0[3] = 1;
  x0[4] = 0;
  x0[5] = 0;
  params[1] = gamma_parameter;
  params[2] = beta_parameter;
  params[3] = sigma_parameter;
  o = sde_euler(x0, ts,  params, tstep, inv_DT,noise );
  x[1] =  o[inv_DT, 5]  - x0[5];
  for (i in int_tstep) {
  int j =  i * 1 / inv_DT + 1;
    x[j] = o[i+inv_DT, 5] - o[i, 5] + 1e-5;
  }
}
model {
  gamma_parameter  ~ lognormal(0, 1);
  beta_parameter   ~ lognormal(0, 1);
  sigma_parameter   ~ lognormal(0, 1);

 // alpha  ~ lognormal(0, 1);
// inv_phi ~ exponential(5);
 // Cases ~ neg_binomial_2(x,phi);
    Cases ~ poisson(x);

}
generated quantities {
  real log_lik;
 //log_lik = neg_binomial_2_lpmf(Cases | x, phi);
  log_lik = poisson_lpmf(Cases|x);

}
