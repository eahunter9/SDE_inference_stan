library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)
library(here)
library(cmdstanr)
library(posterior)
library(tidybayes)
library(tidyr)
library(readsdr)
library(bayesplot)
library(extraDistr)
library(GGally)
library(ggpubr)
library(ggridges)
library(gridExtra)
library(kableExtra)
library(Metrics)
library(patchwork)
library(purrr)
library(readr)
library(scales)
library(stringr)
library(viridisLite)





FILE <- "SEIR_ode.stmx"

mdl        <- read_xmile(FILE)

source("helpers.R")
source("stan_data.R")



sd_stocks(mdl)
sd_constants(mdl) |> 
  mutate(value = format(value, scientific = FALSE))
  
sveir_mdl_sde <- list("cases ~ poisson(net_flow(Total_Cases))")


DT = 1/100

syn <- sd_measurements(n_meas = 1, 
                       ds_input = mdl$deSolve_components,
                       meas_model = sveir_mdl_sde,
                       start_time = 0,
                       stop_time = 50,
                       timestep =  DT,
                       integ_method = "euler") %>% as_tibble()




ggplot(syn,aes(x=time,y=measurement))+geom_point()+geom_line()+
  theme_classic()


stan_filepath <- file.path( "seir_poisson_sde.stan")




stan_d <- list(n_obs      = nrow(syn),
               x0         = c(9999,5,5,0,0), #sd_stocks(mdl)$init_value,
               cases  = syn$measurement,
               t0         = 0,
               n_params = 3,
               n_difeq  = 5,
               Cases = syn$measurement,
              ts         = 1:(nrow(syn)*(1/DT)),
              tstep = DT,
              inv_DT = 1/DT,
              int_tstep = seq(1/DT,(1/DT)*(length(syn$measurement) -1) ,1/DT),
              noise = list(rnorm((nrow(syn)*(1/DT)),0,DT),rnorm((nrow(syn)*(1/DT)),0,DT),rnorm((nrow(syn)*(1/DT)),0,DT))
             )




mod_sde         <- cmdstan_model( stan_filepath)#, include_paths= c("C:/Users/453798/sde_stan"))


fit <- mod_sde$sample(data              = stan_d,
                  chains            = 4,
                  parallel_chains   = 4,
                  iter_warmup       = 1800,
                  iter_sampling     = 1000,
                  refresh           = 100,
                  save_warmup       = FALSE
               #  init = list(initial_1)
                # init_r = .1
                 ) 


fit$diagnostic_summary()

