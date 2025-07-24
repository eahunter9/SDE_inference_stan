#include ode_eulerm_stochastic.stan
data {
 int<lower = 1> n_obs;
 int<lower = 1> n_params;
 int<lower = 1> n_difeq;
 int<lower = 1> inv_DT;
 array[n_obs] int Xt;
 real t0;
 array[n_obs * inv_DT] int ts;
 real tstep;
 array[n_obs -1] int int_tstep;
 array [1] vector[n_obs * inv_DT] noise;
}
parameters {
  real<lower = 0.0001, upper = 1> a;
  real<lower = 0.0001, upper = 1> b;
 //real<lower = 2, upper = 100> m;
  real<lower = 0, upper =1> beta_parameter;
  real<lower = 0.0001, upper = 1> sigma_parameter;
}
transformed parameters{
  array [n_obs * inv_DT] vector [n_difeq] o; // Output from the ODE solver
  array[n_obs] real x;
  vector[n_difeq] x0;
  array[n_params] real params;
  x0[1] = 0.05 ;
  params[1] = a;
  params[2] = sigma_parameter;
  params[3] = b;
 params[4] = beta_parameter;
//  params[4] = sigma_parameter;
  o = sde_euler(x0, ts,  params, tstep, inv_DT,noise );
  x[1] =  o[1, 1];
  for (i in int_tstep) {
    int j =  i * 1 / inv_DT + 1;
    x[j] = o[i, 1] + 1e-5;
  }
}
model {
  a   ~ lognormal(0, 1);
  b  ~ lognormal(0, 1);
 // m  ~ lognormal(0, 1);
  beta_parameter   ~ lognormal(0, 1);
 sigma_parameter   ~ lognormal(0, 1);     

 // alpha  ~ lognormal(0, 1);
// inv_phi ~ exponential(5);
  Xt ~ poisson(x);
}
generated quantities {
  real log_lik;
 log_lik = poisson_lpmf(Xt|x);
}
