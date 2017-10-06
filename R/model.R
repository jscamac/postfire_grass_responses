# Stan model
run_stan_model <- function(data, sim_pretillers=NULL, sim_ldmc = NULL) {
  
  if(is.null(sim_pretillers)) {
    rng <- range(data$Tillers_prefire)
    sim_pretillers <- seq(min(rng),max(rng),1)
  }
  
  if(is.null(sim_ldmc)) {
    rng <- range(data$LDMC)
    sim_ldmc <- seq(min(rng),max(rng),1)
  }
  
  mn_pretillers <- mean(data$Tillers_prefire)
  sd_pretillers <- sd(data$Tillers_prefire)
  
  mn_ldmc <- mean(data$LDMC)
  sd_ldmc <- sd(data$LDMC)
  
  stan_data <- list(
    n_obs = nrow(data),
    n_tribe = max(data$Tribe_ID),
    tribe = data$Tribe_ID,
    tribe_name = data$Tribe,
    n_spp = length(unique(data$Species)),
    spp = as.numeric(factor(data$Species)),
    spp_name = data$Species,
    treatment = data$Treatment_ID-1,
    tillers_prefire = (data$Tillers_prefire - mn_pretillers)/(2*sd_pretillers),
    ldmc = (data$LDMC - mn_ldmc)/(2*sd_ldmc),
    c4 = data$Type_ID-1,
    sim_nobs_pretillers = length(sim_pretillers), # number of pre tiller simulations 
    sim_nobs_ldmc = length(sim_ldmc), # number of ldmc simulations
    sim_pretillers = sim_pretillers,
    sim_ldmc = sim_ldmc,
    cs_sim_pretillers = (sim_pretillers - mn_pretillers) / (2 * sd_pretillers), # CS TPRE values for predictions
    cs_sim_ldmc = (sim_ldmc - mn_ldmc)/ (2 * sd_ldmc), # CS LDMC values for predictions
    y = data$Tillers_postfire)

model ="
data{
  int<lower=0> n_obs;
  int<lower=0> n_spp;
  int<lower=0> n_tribe;
  int<lower=0> tribe[n_obs];
  int<lower=1> spp[n_obs];
  real tillers_prefire[n_obs];
  real ldmc[n_obs];
  int treatment[n_obs];
  real c4[n_obs];
  int<lower=0> y[n_obs];
  int<lower=0> sim_nobs_pretillers;
  int<lower=0> sim_nobs_ldmc;
  real cs_sim_pretillers[sim_nobs_pretillers]; 
  real cs_sim_ldmc[sim_nobs_ldmc]; 
}
parameters{ 
  real a_raw_tribe[n_tribe];
  real a_tribe_mu;
  real<lower=0> a_tribe_sd;
  real a_spp[n_spp];
  real<lower=0> a_spp_sd;
  real a_trt;
  real a_ldmc;
  real a_c4;
  real a_tpre;
  real b_raw_tribe[n_tribe];
  real b_tribe_mu;
  real<lower=0> b_tribe_sd;
  real b_spp[n_spp];
  real<lower=0> b_spp_sd;
  real b_trt;
  real b_ldmc;
  real b_c4;
  real b_tpre;
  real<lower=0, upper=100> phi;
}
transformed parameters {
  real a_tribe[n_tribe];
  real b_tribe[n_tribe];
  real count[n_obs];
  real p_death[n_obs];

  for (t in 1:n_tribe) {
  // same as normal(a_tribe_mu, a_tribe_sd)
  a_tribe[t] = a_raw_tribe[t] * a_tribe_sd + a_tribe_mu;
  // noncentered param: same as normal(b_tribe_mu, b_tribe_sd)
  b_tribe[t] = b_raw_tribe[t] * b_tribe_sd + b_tribe_mu; 
  }
  for (i in 1:n_obs) {
    count[i] = exp(b_tribe[tribe[i]] + b_spp[spp[i]] + b_trt * treatment[i] + b_c4 * c4[i] + b_ldmc * ldmc[i] + b_tpre * tillers_prefire[i]);
    p_death[i] = inv_logit(a_tribe[tribe[i]] + a_spp[spp[i]] + a_trt * treatment[i] + a_c4 * c4[i] + a_ldmc * ldmc[i] + a_tpre * tillers_prefire[i]);
  }
}
model { 
  a_tribe_mu ~ cauchy(0,5);
  a_tribe_sd ~ cauchy(0,5);
  a_raw_tribe ~ normal(0,1);
  a_spp ~ normal(0, a_spp_sd);
  a_spp_sd ~ cauchy(0,5);
  a_trt ~ cauchy(0,5);
  a_ldmc ~ cauchy(0,5);
  a_c4 ~ cauchy(0,5);
  a_tpre ~ cauchy(0,5);
  b_tribe_mu ~ cauchy(0,5);
  b_tribe_sd ~ cauchy(0,5);
  b_raw_tribe ~ normal(0,1);
  b_spp ~ normal(0, b_spp_sd);
  b_spp_sd ~ cauchy(0,5);
  b_trt ~ normal(0,5);
  b_ldmc ~ normal(0,5);
  b_c4 ~ normal(0,5);
  b_tpre ~ normal(0,5);
  
  // Likelihood
  
  for (i in 1:n_obs){
    if (y[i] == 0) { // if does not survive
      target +=(log_sum_exp(bernoulli_lpmf(1 | p_death[i]),
                                     bernoulli_lpmf(0 | p_death[i])
                                     + neg_binomial_2_lpmf(y[i] | count[i], phi)));
    } else { // if survives
      target +=(bernoulli_lpmf(0 | p_death[i])
                         + neg_binomial_2_lpmf(y[i] | count[i], phi));
    }
  }
}
generated quantities { 
  real pred[n_obs];
  real resid[n_obs];
  real log_lik[n_obs];
  
  real pred_p_death_4day_c3;
  real pred_p_death_4day_c4;
  real pred_p_death_8day_c3;
  real pred_p_death_8day_c4;
  real pred_p_death_11day_c3;
  real pred_p_death_11day_c4;
  
  real pred_count_4day_c3;
  real pred_count_4day_c4;
  real pred_count_8day_c3;
  real pred_count_8day_c4;
  real pred_count_11day_c3;
  real pred_count_11day_c4;
  
  real pred_p_death_c3_tpre[sim_nobs_pretillers];
  real pred_p_death_c4_tpre[sim_nobs_pretillers];
  real pred_p_death_c3_ldmc[sim_nobs_ldmc];
  real pred_p_death_c4_ldmc[sim_nobs_ldmc];
  
  real pred_count_c3_tpre[sim_nobs_pretillers];
  real pred_count_c4_tpre[sim_nobs_pretillers];
  real pred_count_c3_ldmc[sim_nobs_ldmc];
  real pred_count_c4_ldmc[sim_nobs_ldmc];
  
  // Estimate log likelihood
  for (i in 1:n_obs) {
    if (y[i]== 0) {
      log_lik[i] = log_sum_exp(bernoulli_lpmf(1 | p_death[i]),
                                bernoulli_lpmf(0 | p_death[i])
                                + neg_binomial_2_lpmf(y[i] | count[i], phi));
  }
    else {
      log_lik[i] = bernoulli_lpmf(0 | p_death[i]) + neg_binomial_2_lpmf(y[i]| count[i], phi);
    }
    pred[i] = (1-p_death[i]) * count[i];
    resid[i] = (y[i] - pred[i])/sqrt(pred[i] + (phi * pred[i]^2));
  }
  
  // Partial dependencies of TRT & C3/C4
  pred_p_death_4day_c3 = inv_logit(a_tribe_mu);
  pred_p_death_4day_c4 = inv_logit(a_tribe_mu + a_c4);
  pred_p_death_8day_c3 = inv_logit(a_tribe_mu + a_trt);
  pred_p_death_8day_c4 = inv_logit(a_tribe_mu + a_trt + a_c4);
  pred_p_death_11day_c3 = inv_logit(a_tribe_mu + a_trt * 2);
  pred_p_death_11day_c4 = inv_logit(a_tribe_mu + a_trt * 2 + a_c4);
  
  pred_count_4day_c3 = exp(b_tribe_mu);
  pred_count_4day_c4 = exp(b_tribe_mu + b_c4);
  pred_count_8day_c3 = exp(b_tribe_mu + b_trt);
  pred_count_8day_c4 = exp(b_tribe_mu + b_trt + b_c4);
  pred_count_11day_c3 = exp(b_tribe_mu + b_trt * 2);
  pred_count_11day_c4 = exp(b_tribe_mu + b_trt * 2 + b_c4);
  
  // Partial dependencies tillers prefire
  for (j in 1:sim_nobs_pretillers) {
    pred_p_death_c3_tpre[j] = inv_logit(a_tribe_mu + a_tpre * cs_sim_pretillers[j]);
    pred_p_death_c4_tpre[j] = inv_logit(a_tribe_mu + a_tpre * cs_sim_pretillers[j] + a_c4);
    pred_count_c3_tpre[j] = exp(b_tribe_mu + b_tpre * cs_sim_pretillers[j]);
    pred_count_c4_tpre[j] = exp(b_tribe_mu + b_tpre * cs_sim_pretillers[j] + b_c4);
  }
  
  // Partial dependencies ldmc
  for (k in 1:sim_nobs_ldmc) {
    pred_p_death_c3_ldmc[k] = inv_logit(a_tribe_mu + a_ldmc * cs_sim_ldmc[k]);
    pred_p_death_c4_ldmc[k] = inv_logit(a_tribe_mu + a_ldmc * cs_sim_ldmc[k] + a_c4);
    pred_count_c3_ldmc[k] = exp(b_tribe_mu + b_ldmc * cs_sim_ldmc[k]);
    pred_count_c4_ldmc[k] = exp(b_tribe_mu + b_ldmc * cs_sim_ldmc[k] + b_c4);
    }
}"

fit <- list(stan_data = stan_data,
            fit = stan(model_code = model,
                       data= stan_data,
                       pars = c('a_tribe_mu','b_tribe_mu','a_tribe_sd','b_tribe_sd',
                                'a_spp_sd','b_spp_sd',
                                'a_tribe','a_spp','a_trt','a_ldmc','a_c4','a_tpre',
                                'b_tribe','b_spp','b_trt','b_ldmc','b_c4','b_tpre','phi',
                                'pred_p_death_4day_c3', 'pred_p_death_4day_c4',
                                'pred_p_death_8day_c3', 'pred_p_death_8day_c4',
                                'pred_p_death_11day_c3', 'pred_p_death_11day_c4',
                                'pred_count_4day_c3', 'pred_count_4day_c4',
                                'pred_count_8day_c3', 'pred_count_8day_c4',
                                'pred_count_11day_c3', 'pred_count_11day_c4',
                                'pred_p_death_c3_tpre', 'pred_count_c3_tpre',
                                'pred_p_death_c4_tpre', 'pred_count_c4_tpre',
                                'pred_p_death_c3_ldmc', 'pred_count_c3_ldmc',
                                'pred_p_death_c4_ldmc', 'pred_count_c4_ldmc'),
                       cores = 3,
                       chains = 3,
                       iter = 1000,
                       control= list(adapt_delta=0.99, max_treedepth=15)))
return(fit)
}
