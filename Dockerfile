#FROM jupyter/datascience-notebook:612aa5710bf9
FROM jupyter/datascience-notebook:95ccda3619d0

# Add RUN statements to install packages as the $NB_USER defined in the base images.

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.
RUN conda install -yq -c conda-forge jupyter-server-proxy jupyter-rsession-proxy && \
    conda clean -tipsy

## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide
## install rstudio-server
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libapparmor1 \
    libclang-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    procps \
    python-setuptools \
    wget \
  && wget -q http://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5042-amd64.deb \
  && dpkg -i rstudio-server-*-amd64.deb \
  && rm rstudio-server-*-amd64.deb

#RUN R -e "install.packages('devtools', dependencies=TRUE, repos='http://cran.rstudio.com/')"
#RUN R -e "library(devtools)"
RUN R -e "install.packages('testthat', dependencies = TRUE, repos='http://cran.rstudio.com/')"
ENV PATH=$PATH:/usr/lib/rstudio-server/bin
USER $NB_USER
# Add RISE to the mix as well so user can show live slideshows from their notebooks
# More info at https://rise.readthedocs.io
# Note: Installing RISE with --no-deps because all the neeeded deps are already present.
RUN conda install rise
# Add nbgitpuller
RUN pip install nbgitpuller
# Add xlrd, openpyxl, and lxml
RUN pip install xlrd openpyxl lxml jupyter-resource-usage
