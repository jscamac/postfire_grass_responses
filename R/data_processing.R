
# Prepares data for model
load_data <- function(file) {
read_csv(file, col_types=cols_only(
  Treatment = col_factor(c("4 Days", "8 Days", "11 Days")),
  Species = "c",
  Tribe = "c",
  Tillers_cm2 = "d",
  Tillers_postfire = "i",
  Type = col_factor(c("C3","C4")),
  LDMC = "d")) %>%
  mutate(Treatment_ID = as.numeric(Treatment),
         Type_ID = as.numeric(Type),
         Tribe_ID = as.numeric(as.factor(Tribe))) %>%
    select(Treatment, Treatment_ID, Tribe, Tribe_ID, Species, Tillers_prefire = Tillers_cm2, Tillers_postfire, Type, Type_ID, LDMC)
}


# Summaries regression coefficients
summarise_coefficients <- function(model, params, quantiles = c(0.025,0.1,0.5,0.9, 0.975)) {
  samples <- rstan::extract(model$fit, pars=params)
  
  res <-lapply(samples, function(x) {
    if(is.matrix(x)) {
      df <- cbind.data.frame(
        mean = apply(x,2, mean),
        sd = apply(x,2,sd),
        aperm(apply(x,2, quantile, quantiles), c(2,1)))
      df
    }
    else {
      df <- cbind.data.frame(
        mean = mean(x),
        sd = sd(x),
        t(quantile(x, quantiles)))
      df
    }
  })
  plyr::ldply(res, .id='parameter')
}
