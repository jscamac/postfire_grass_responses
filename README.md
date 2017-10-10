# Most temperate Australian perennial native grasses respond to drought and fire by resprouting

By *Nicholas A. Moore, James S. Camac and John W. Morgan*

Fire is an integral ecological process affecting grassland ecosystems since the Miocene. However, little is known as to how perennial grass species with different evolutionary histories and photosynthetic pathways respond to fire, or how such responses varies with plant stress at the time of burning. In this study we use a glasshouse drought experiment coupled with experimental burning to examine post-fire resprouting capacity --- measured as the probability of surviving fire and the number of resprouting tillers, assuming survival. We ask: (i) Does post-fire resprout capacity, vary between C3 and C4 photosynthetic pathways? (ii) Does response vary by grass tribe? And (iii) does post-fire resprouting vary with pre-fire drought stress?  

We examined responses of 52 temperate perennial Australian grass species, spanning 37 genera. Before experimental burning, three watering frequencies were applied for 35 days to simulate increasing drought. Photosynthetic pathways, watering treatment, Pre-fire tiller density and Leaf Dry Matter Content were measured as explanatory variables to assess fire response (survival and number of post-fire tillers given survival). 

This repository contains the data and code to reproduce the analysis and figures.

**Paper is currently in review**


## Reproducing analysis
We are committed to reproducible science. As such, this repository contains all the data and code necessary to fully reproduce our results. To facilitate the reproducibility of this work, we have created a docker image and set up the entire workflow using [remake](https://github.com/richfitz/remake). Below we outline the steps required to reproduce the analyses, figures and manuscript.

## Installing remake

First install some dependencies from cran as follows:

```r
install.packages(c("R6", "yaml", "digest", "crayon", "optparse"))
```

Now we'll install some packages from [github](github.com). For this, you'll need the package [devtools](https://github.com/hadley/devtools). If you don't have devtools installed you will see an error "there is no package called 'devtools'"; if that happens install devtools with `install.packages("devtools")`.


Then install the following two packages

```r
devtools::install_github("richfitz/storr")
devtools::install_github("richfitz/remake")
```
See the info in the [remake readme](https://github.com/richfitz/remake) for further details if needed.

## Running remake locally

### Copy repository
First copy the repository to your a desired directory on you local computer. 

This can either be done using the terminal (assuming git is installed)

```
git clone https://github.com/jscamac/postfire_grass_responses.git
```

Or can be downloaded manually by clicking [here](https://github.com/jscamac/postfire_grass_responses/archive/master.zip).

Now open a new R session with this project set as working directory. We use a number of packages, these can be easily installed by remake:

```r
remake::install_missing_packages()
```

Then run the following to generate all outputs (figures, table, knitr report):

```r
remake::make()
```

For comparison, also included is a traditional script `Rscript.R` that generates the same outputs, without using remake. This script is automatically generated from the `remake.yml` file, as part of the remake workflow.


## Running remake via docker

Each computer is different. Operating systems, software install and the versions of such software are likely to vary substantially between computers. As such it is extremely difficult to develop code that can easily run on all computers. This is where Docker comes in. [Docker](https://www.docker.com/what-docker) is the world’s leading software container platform.  Here we use Docker because it can readily be used across platforms and is set to install the appropriate software, and software versions used in the original analysis. As such it safeguards code from differences among computers and potential changes in software and cross platform issues.

### Setting up Docker
If you haven't installed docker please see [here](https://www.docker.com/products/overview).

We can set up docker two ways. If a docker image already exists on Docker Hub you can just download it by running something like the following:

```
docker pull jscamac/rstan_build
```
This image contains all required software to run this analysis.


If however, the image is not available or you've created your own Dockerfile you can build it. This will be slower relative to the `docker pull` approach as it requires compiling the whole image.

```
docker build --rm --no-cache -t rstan_build .

```
**The period is important as it tells docker to look for the dockerfile in the current directory**

## Using docker
Now we are all set to reproduce this project!

Now there are two common ways we can interface with the docker container:
If your image only includes base `R` you can access it via the terminal by opening a terminal and running:

### Accessing the docker terminal
If you're comfortable with running work directly via R from a terminal or your image only includes base `R` run:

```
docker run -v /Users/path/to/repository/:/home/rstan_build  -it jscamac/rstan_build

```

### Accessing Rstudio from within docker
If you are more comfortable with running code using a GUI interface such as Rstudio, you can open set run docker such that you interface directly with Docker's Rstudio.
To do this you must have a docker image that contains Rstudio.

```
docker run -v /Users/path/to/repository/:/home/rstan_build:/home/rstudio -p 8787:8787 rstan_build
```
Now just open your web browser and go to the following: `localhost:8787/`

The username and password is `rstudio`

### Rerunning analysis from within docker
Now the final stage is to rerun the entire workflow by simply running:

```
remake::make()
```


## Problems?
If you have any problems getting the workflow to run please create an issue and I will endevour to remedy it ASAP.