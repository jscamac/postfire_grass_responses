# Plots coefficients
coefficient_plot <- function(model, params ='count',xlab ='Effect size', title=NULL) {
  if(params == "count") {
    output <- summarise_coefficients(model, rev(c('b_tribe_mu',"b_trt","b_c4","b_ldmc","b_tpre","phi")))
    y_axis_labels= rev(c("Intercept", "Treatment","C4","LDMC","Tiller density",expression(phi)))
  } 
  if(params =="mortality") {
    output <- summarise_coefficients(model, rev(c('a_tribe_mu',"a_trt","a_c4","a_ldmc","a_tpre")))
    y_axis_labels= rev(c("Intercept", "Treatment","C4","LDMC","Tiller density"))
  }
  
  if(!params %in% c("count", "mortality")) {
    stop("params can only be `count` or `mortality`")
  }
  
  ggplot(output, aes(x = mean,y = parameter)) + 
    geom_segment(aes(x=`10%`,y=parameter, xend=`90%`, yend=parameter), size=1) +
    geom_segment(aes(x=`2.5%`,y=parameter, xend=`97.5%`, yend=parameter)) +
    geom_point(aes(x=mean, y=parameter)) +
    geom_vline(aes(xintercept=0), linetype=2) +
    scale_y_discrete(labels =y_axis_labels) +
    xlab(xlab) +
    ylab("Parameter") +
    scale_x_continuous(breaks= scales::pretty_breaks(4)) +
    labs(title=title) +
    theme_classic()
}

# Plots discrete predictor partial plots
plot_pred_discrete <- function(model,params = "count", xlab="Days between watering", legend="right") {
  
  if(params == "count") { 
    output <- summarise_coefficients(model, c('pred_count_4day_c3', 'pred_count_4day_c4',
                                              'pred_count_8day_c3', 'pred_count_8day_c4',
                                              'pred_count_11day_c3', 'pred_count_11day_c4'))
    ylab=expression("Number of postfire tillers")
  }
  
  if(params == "mortality") { 
    output <- summarise_coefficients(model, c('pred_p_death_4day_c3', 'pred_p_death_4day_c4',
                                              'pred_p_death_8day_c3', 'pred_p_death_8day_c4',
                                              'pred_p_death_11day_c3', 'pred_p_death_11day_c4'))
    ylab="Probability of death"
  }
  
  if(!params %in% c("count", "mortality")) {
    stop("params can only be `count` or `mortality`")
  }
  
  output <- output %>%
    mutate(Treatment = factor(ifelse(grepl("4day",output$parameter)==TRUE, "4 days",
                                     ifelse(grepl("8day",output$parameter)==TRUE, "8 days", "11 days")),
                              levels = c("4 days","8 days","11 days")),
           Type = factor(ifelse(grepl("c3", output$parameter)==TRUE, "C3", "C4")))
  
  ggplot(output, aes(x = Treatment,y = mean, group= Type, fill=Type)) + 
    geom_linerange(aes(ymin = `2.5%`, ymax=`97.5%`), position=position_dodge(.2)) +
    geom_linerange(aes(ymin = `10%`, ymax=`90%`), position=position_dodge(.2), size=1) +
    geom_point(shape = 21, position=position_dodge(.2)) +
    scale_fill_manual("",values = c(C3 ="white",C4 ="black")) +
    ylab(ylab) + 
    xlab(xlab) +
    theme_classic() +
    theme(legend.position=legend)
}

# Plots continous predictor partial plots
plot_pred_continuous <- function(model, params, covariate, xlab="Days between watering", xlim=NULL, ylim=NULL, legend="right") {
  
  if(params == "count" & covariate == "prefire tillers") { 
    output <- summarise_coefficients(model, c('pred_count_c3_tpre', 'pred_count_c4_tpre')) %>%
      mutate(sim = rep(model$stan_data$sim_pretillers,2),
             Type = factor(ifelse(grepl("c3", .$parameter)==TRUE, "C3", "C4")))
    
    ylab=expression("Number of postfire tillers")
    xlab=expression("Prefire tiller density"~(cm^{-2}))
  }
  
  if(params == "count" & covariate == "ldmc") { 
    output <- summarise_coefficients(model, c('pred_count_c3_ldmc', 'pred_count_c4_ldmc')) %>%
      mutate(sim = rep(model$stan_data$sim_ldmc,2),
             Type = factor(ifelse(grepl("c3", .$parameter)==TRUE, "C3", "C4")))
    
    ylab=expression("Number of postfire tillers")
    xlab=expression("Leaf dry matter content"~(mg~g^{-1}))
  }
  
  if(params == "mortality" & covariate == "prefire tillers") { 
    output <- summarise_coefficients(model, c('pred_p_death_c3_tpre', 'pred_p_death_c4_tpre')) %>%
      mutate(sim = rep(model$stan_data$sim_pretillers,2),
             Type = factor(ifelse(grepl("c3", .$parameter)==TRUE, "C3", "C4")))
    
    ylab=expression("Probability of death")
    xlab=expression("Prefire tiller density"~(cm^{-2}))
  }
  
  if(params == "mortality" & covariate == "ldmc") { 
    output <- summarise_coefficients(model, c('pred_p_death_c3_ldmc', 'pred_p_death_c4_ldmc')) %>%
      mutate(sim = rep(model$stan_data$sim_ldmc,2),
             Type = factor(ifelse(grepl("c3", .$parameter)==TRUE, "C3", "C4")))
    
    ylab=expression("Probability of death")
    xlab=expression("Leaf dry matter content"~(mg~g^{-1}))
  }
  
  if(!params %in% c("count", "mortality")) {
    stop("params can only be `count` or `mortality`")
  }
  
  if(!covariate %in% c("prefire tillers", "ldmc")) {
    stop("covariate can only be `prefire tillers` or `ldmc`")
  }
  ggplot(output, aes_string(x = 'sim',y = 'mean', group ='Type', fill ='Type', col='Type', linetype="Type"), 
         axis.line = element_line()) + 
    scale_colour_manual("",values= c(C4 ="#5e3c99",C3 ="#e66101")) +
    scale_fill_manual("",values= c(C4 ="#5e3c99",C3 ="#e66101")) +
    scale_linetype_manual("",values=c(C4 ="dashed", C3="solid")) +
    geom_ribbon(aes(ymin = `2.5%`,ymax = `97.5%`), alpha=0.6, colour=NA) + 
    geom_line() +
    coord_cartesian(xlim = xlim, ylim=ylim, expand = FALSE) +
    xlab(xlab) +
    ylab(ylab) +
    theme_classic() + theme(legend.position=legend)
}

# Plots mortality panel plots
plot_partial_mortality <- function(model) {
  p1 <- coefficient_plot(model, "mortality", xlab ='logit(Coefficient)')
  p2 <- plot_pred_discrete(model, "mortality", legend=c(0.85,0.8))
  p3 <- plot_pred_continuous(model,"mortality","ldmc", ylim=c(0,1),  legend="none")
  p4 <- plot_pred_continuous(model,"mortality","prefire tillers", ylim=c(0,1), legend=c(0.85,0.8))
  cowplot::plot_grid(p1,p2,p3,p4, ncol=2, labels=paste0('(',letters[1:4],')'), label_size = 9)
}

# Plots count panel plots
plot_partial_count <- function(model) {
  p1 <- coefficient_plot(model, xlab ='log(Coefficient)')
  p2 <- plot_pred_discrete(model, "count", legend=c(0.25,0.8))
  p3 <- plot_pred_continuous(model,"count","ldmc",  legend="none")
  p4 <- plot_pred_continuous(model,"count","prefire tillers", legend=c(0.25,0.8))
  cowplot::plot_grid(p1,p2,p3,p4, ncol=2, labels=paste0('(',letters[1:4],')'), label_size = 9)
}

# Plots random effects
plot_random_effect <- function(model,random_effect,xlab ='Effects', title=NULL, legend="none") {
  
  if(random_effect %in% c("a_tribe", "b_tribe")) {
    df <- unique(data.frame(name = model$stan_data$tribe_name, 
                            code =model$stan_data$tribe, 
                            type = as.factor(model$stan_data$c4))) %>%
      arrange(code)
  }
  
  if(random_effect %in% c("a_spp", "b_spp")) {
    df <- unique(data.frame(name = model$stan_data$spp_name, 
                            code =model$stan_data$spp, 
                            type = as.factor(model$stan_data$c4))) %>%
      arrange(code)
  }
  
  dat <- summarise_coefficients(model,random_effect) %>%
    cbind(df,.) %>%
    mutate(ID = as.factor(paste0(name,"_",type))) %>%
    mutate(ID = factor(ID, levels=ID[order(mean)], ordered=TRUE)) %>%
    arrange(ID)
  
  #Plot 
  ggplot(dat, aes(x = mean,y = ID, col=type)) + 
    geom_segment(aes(x=`2.5%`,y=ID, xend=`97.5%`, yend=ID), size =0.25) +
    geom_segment(aes(x=`10%`,y=ID, xend=`90%`, yend=ID), size=0.5) +
    geom_point(aes(x=mean, y=ID), size=0.5) +
    scale_y_discrete(labels = dat$name) +
    scale_colour_manual("", values=c("0" ="black","1"="red"), 
                        labels = c("C3", "C4")) +
    xlab(xlab) +
    ylab(NULL) +
    labs(title=title) +
    theme_classic() +
    theme(axis.text.y=element_text(face="italic"), legend.position=legend,
          plot.title = element_text(hjust = 0.5, size=7, face ="bold"))
}

# Plots panel plots of tribe effects
plot_tribe_effects <- function(model) {
  p1 <- plot_random_effect(model, "a_tribe", "logit(effect)", title="Mortality model",  legend = c(0.90,0.5)) +
    theme(text = element_text(size=7))
  p2 <- plot_random_effect(model, "b_tribe", "log(effect)", title="Post-fire tiller abundance model") +
    theme(text = element_text(size=7))
  cowplot::plot_grid(p1,p2, ncol=1, labels=paste0('(',letters[1:2],')'), label_size = 7)
}

# Plots panel plots of species effects
plot_spp_effects <- function(model) {
  p1 <- plot_random_effect(model, "a_spp", "logit(effect)", title="Mortality model", legend = c(0.90,0.5)) + 
    theme(text = element_text(size=7),
          axis.text.y = element_text(size=3.5))
  
  p2 <- plot_random_effect(model, "b_spp", "log(effect)", title="Post-fire tiller abundance model") + 
    theme(text = element_text(size=7),
          axis.text.y = element_text(size=3.5))
  cowplot::plot_grid(p1,p2, ncol=1, labels=paste0('(',letters[1:2],')'), label_size = 9)
}