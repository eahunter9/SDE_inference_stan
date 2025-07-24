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




FILE <- "tumor growth ode.stmx"


mdl        <- read_xmile(FILE)

source("helpers.R")

source("stan_data.R")



sd_stocks(mdl)
sd_constants(mdl) |> 
  mutate(value = format(value, scientific = FALSE))

tumor_sde <- list("Xt ~ poisson(X)")


DT = 1/50

syn <- sd_measurements(n_meas = 1, 
                       ds_input = mdl$deSolve_components,
                       meas_model = tumor_sde,
                       start_time = 0,
                       stop_time = 250,
                       timestep =  DT,
                       integ_method = "euler") %>% as_tibble()

ggplot(syn,aes(x=time,y=measurement))+geom_point()+geom_line()+
  theme_classic()

tumor_syn_2 <- sd_simulate( 
  ds_input = mdl$deSolve_components,
  start_time = 0,
  stop_time = 250,
  timestep = 1,
  integ_method = "euler") %>% as_tibble()
syn <- as.tibble(cbind(as.numeric(tumor_syn_2$time),as.numeric(tumor_syn_2$X)))
colnames(syn) <- c("time","measurement")





stan_d <- list(n_obs      = nrow(syn),
               x0         = c(0.5), #sd_stocks(mdl)$init_value,
               t0         = 0,
               n_params = 4,
               n_difeq  = 1,
               Xt = syn$measurement,
             # Xt = tumor_syn_2$X,
              
               ts         = 1:(nrow(syn)*(1/DT)),
               tstep = DT,
               inv_DT = 1/DT,
               int_tstep = seq(1/DT,(1/DT)*(length(syn$measurement) -1) ,1/DT),
               noise = list(rnorm((nrow(syn)*(1/DT)),0,DT))#^.5)
)

stan_filepath <- file.path( "tumor_poisson_sde.stan")



mod_sde         <- cmdstan_model(stan_filepath)#, include_paths= c("C:/Users/453798/sde_stan"))


fit <- mod_sde$sample(data              = stan_d,
                      chains            = 4,
                      parallel_chains   = 4,
                      iter_warmup       = 1000,
                      iter_sampling     = 1000,
                      refresh           = 100,
                      save_warmup       = FALSE
                      #  init = list(initial_1)
                      # init_r = .1
) 



fit$diagnostic_summary()


posterior_tumor <-  as_draws_df(fit$draws()) %>%
  as_tibble()



