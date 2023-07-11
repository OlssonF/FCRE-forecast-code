FROM rocker/geospatial:4.1.2

RUN apt-get update && apt-get -y install libgd-dev libnetcdf-dev git

USER rstudio

RUN git clone https://github.com/OlssonF/FCRE-forecast-code.git /home/rstudio/FCRE-forecast-code

RUN Rscript /home/rstudio/FCRE-forecast-code/workflows/ler_ms/install_packages.R

USER root
