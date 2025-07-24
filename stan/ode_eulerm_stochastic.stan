
functions{
// #include SEIR.stan
#include geometric_random_walk.stan
//#include tumorgrowth.stan
#include obesity.stan
array [] vector sde_euler( vector y, array[] int times, array[] real parms, real DT, int inv_DT,  array [] vector noise){ 
 //int n_col = (size(y) * inv_DT);
 array [size(noise[,1])] real noise_t = noise[1:size(noise[,1]),1];

// array[3] vector[size(y)] pre_call =  MDL(times[1], y, parms, noise_t);

 vector [size(y)] y_new = y;

 array[size(times)] vector[size(y)] o;

 for(j in 1:(size(y))){
 for(i in 1:size(times)){
 o[i,j] = 0;
 }
 }


 int row_index =  1;

 for(i in 1:(size(y))){
 o[row_index,i] = y[i];
 }



 for(t in times){
 noise_t = noise[1:size(noise[,1]),t];

 array[3] vector[size(y)] flows_auxs = MDL(row_index, y_new, parms, noise_t);
 vector [size(y)] delta_yd = flows_auxs[2];
 vector[size(y)] delta_ys = flows_auxs[3];
 for(i in 1:(size(y))){
  o[row_index,i] = y_new[i];
  }
//print(y_new);
//print(delta_yd);
//print(delta_ys);
for(i in 1:size(y)){
 y_new[i] = y_new[i] + delta_yd[i] * DT + delta_ys[i]; //* noise[t]; //* (noise[t+1] - noise[t]);

}
 row_index = row_index + 1;
 }


 return o;
 }
}