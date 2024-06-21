# syntax=docker/dockerfile:1.2
FROM --platform=linux/amd64 rocker/tidyverse:4.3.2
RUN Rscript -e "install.packages('remotes'); \
    remotes::install_version('testthat', version = '3.2.1', dependencies = TRUE); \
    remotes::install_version('ggplot2', version = '3.5.0', dependencies = TRUE); \
    remotes::install_version('dplyr', version = '1.1.4', dependencies = TRUE);"
