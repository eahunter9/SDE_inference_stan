array [] vector MDL(real time, vector y, array[] real params, array[] real  noise) {
  array[3] vector[size(y)] Y;
  vector[size(y)] dydt;
  vector[size(y)] y_d;
  vector[size(y)] y_s;
  real dW1;
  real dW2;
  real T = (12.3654/(2.75197 + 1.71503*2.71828^(-0.04813843*time)));
  dW1 = geometric_random_walk(noise[1],params[4]);
  dW2 = geometric_random_walk(noise[2],params[5]);
  y_d[1] = 0.0491843 * y[1]*(1 - T/4.47700) + params[1]*((T - y[1] - y[2])/T)*(y[1] + y[2]) - (params[6] + params[2]) * y[1] + params[3]*y[2];
  y_d[2] = 0.0491843 * y[2]*(1 - T/4.47700) + params[2]* y[1] - params[3]*y[2];
  y_s[1] = dW1;
  y_s[2] = dW2;
  dydt[1] = 0.0491843 * y[1]*(1 - T/4.47700) + params[1]*((T - y[1] - y[2])/T)*(y[1] + y[2]) - (params[6] + params[2]) * y[1] + params[3]*y[2] + dW1;
  dydt[2] =  0.0491843 * y[2]*(1 - T/4.47700) + params[2]* y[1] - params[3]*y[2] + dW2;
  Y[1] = dydt;
  //print(dydt);
 // print(y_d);
 // print(y_s);
  Y[2] = y_d;
  Y[3] = y_s;
  return Y;
}