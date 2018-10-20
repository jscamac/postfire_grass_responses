# Most temperate Australian perennial native grasses respond to drought and fire by resprouting

By *Nicholas A. Moore, James S. Camac and John W. Morgan*

Fire is an integral ecological process affecting grassland ecosystems since the Miocene. However, little is known as to how perennial grass species with different evolutionary histories and photosynthetic pathways respond to fire, or how such responses varies with plant stress at the time of burning. In this study we use a glasshouse drought experiment coupled with experimental burning to examine post-fire resprouting capacity --- measured as the probability of surviving fire and the number of resprouting tillers, assuming survival. We ask: (i) Does post-fire resprout capacity, vary between C3 and C4 photosynthetic pathways? (ii) Does response vary by grass tribe? And (iii) does post-fire resprouting vary with pre-fire drought stress?  

We examined responses of 52 temperate perennial Australian grass species, spanning 37 genera. Before experimental burning, three watering frequencies were applied for 35 days to simulate increasing drought. Photosynthetic pathways, watering treatment, Pre-fire tiller density and Leaf Dry Matter Content were measured as explanatory variables to assess fire response (survival and number of post-fire tillers given survival). 

This repository contains the data and code to reproduce the analysis and figures.

**Paper is has been published in New Phytologist**

https://nph.onlinelibrary.wiley.com/doi/abs/10.1111/nph.15480


## Reproducing analysis
We are committed to reproducible science. As such, this repository contains all the data and code necessary to fully reproduce our results. To facilitate the reproducibility of this work, we have created a docker image and set up the entire workflow using [remake](https://github.com/richfitz/remake). Below we outline the two approaches that can be taken to reproduce the analyses, figures and manuscript.

### Copy repository
First copy the repository to your a desired directory on you local computer. 

This can either be done using the terminal (assuming git is installed)

```
git clone https://github.com/jscamac/postfire_grass_responses.git
```

Or can be downloaded manually by clicking [here](https://github.com/jscamac/postfire_grass_responses/archive/master.zip).

## Reproducing analysis with remake & docker

Each computer is different. Operating systems, software install and the versions of such software are likely to vary substantially between computers. As such it is extremely difficult to develop code that can easily run on all computers. This is where Docker comes in. [Docker](https://www.docker.com/what-docker) is the world’s leading software container platform.  Here we use Docker because it can readily be used across platforms and is set to install the appropriate software, and software versions used in the original analysis. As such it safeguards code from differences among computers and potential changes in software and cross platform issues.

### Setting up Docker
If you haven't installed docker please see [here](https://www.docker.com/products/overview).

Because some of the data compilation is memory intensive. We suggest you allow docker to access at least 4GB of your systems RAM. This can easily be done within docker's settings and it's associated sliders.

We can set up docker two ways. The recommended approach is to download the precompiled docker image by running the following in the terminal/shell:

```
docker pull jscamac/grass_resprout
```
This image contains all required software (and software versions) to run this analysis.


If however, you would like the recompile the image from scratch the code below can be run. Note this will much slower relative to the `docker pull` approach.

```
docker build --rm --no-cache -t jscamac/grass_resprout .

```
**The period is important as it tells docker to look for the dockerfile in the current directory**

## Using docker
Now we are all set to reproduce this project!

### Rstudio from within docker
To be able to run the code, we interface with the Rstudio within the docker container by running the following in the terminal/shell (**NOTE** path to directory will need to be changed):

```
docker run -e DISABLE_AUTH=true -v /Users/path/to/repository/:/home/rstudio -p 8787:8787 jscamac/grass_resprout

```
Now just open your web browser and go to the following: `localhost:8787/`. This should open an Rstudio server session.

### Rerunning analysis from within docker
Within the Rstudio browser one can then reprdouce the analysis, key analysis figures and supplementary using:

```
remake::make()
```


## Problems?
If you have any problems getting the workflow to run please create an issue and I will endevour to remedy it ASAP.