
array [] vector MDL(real time, vector y, array[] real params, array[] real  noise) {
  array[3] vector[size(y)] Y;
  vector[size(y)] dydt;
  vector[size(y)] y_d;
  vector[size(y)] y_s;
  real dW1;
  dW1 = noise[1] * (params[2]*y[1]);
  y_d[1] = (params[1] -params[3]*y[1]^(2-1))*y[1] - (params[4]*y[1]^2)/(1+y[1]^2);
  y_s[1] = dW1;
  dydt[1] = (params[1] -params[3]*y[1]^(2 -1))*y[1] - (params[4]*y[1]^2)/(1+y[1]^2) + dW1;
  Y[1] = dydt;
  Y[2] = y_d;
  Y[3] = y_s;
  return Y;
}





