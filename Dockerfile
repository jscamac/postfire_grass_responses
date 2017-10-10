FROM rocker/verse:3.4.1
LABEL maintainer="James Camac"
LABEL email="james.camac@gmail.com"

## Update and install extra packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    clang \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

## Add in opts
# Global site-wide config for clang
RUN mkdir -p $HOME/.R/ \
    && echo "\nCXX=clang++ -ftemplate-depth-256\n" >> $HOME/.R/Makevars \
    && echo "CC=clang\n" >> $HOME/.R/Makevars

## Add in require R packages

RUN . /etc/environment \
  && install2.r --error --repos $MRAN --deps FALSE \
    R6 yaml digest crayon getopt optparse cowplot StanHeaders Rcpp RcppEigen BH inline rstan rmarkdown bookdown 

## Hi res data and remake
RUN . /etc/environment \
  && installGithub.r \
  richfitz/storr \
  richfitz/remake

# Remove unnecessary tmp files
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Set working directory
WORKDIR /home/grass_resprouting/