# FCRE-forecast-code

This code reproduces figures from the Falling Creek Reservoir multi-model ensemble forecasting research using baseline forecasts and the FLARE (Forecasting Lake And Reservoir Ecosystems) system in the manuscript by Olsson et al. titled "TBD" If you have any questions, contact Freya Olsson at freyao\@vt.edu

# Instructions to reproduce manuscript + SI figures:

1.  Download or clone github repository to your local computer

2.  Run `install_packages.R` in the `workflows/ler_ms` folder to download GLM and FLARE packages and their dependencies

3.  Run `download_scores.R` in the `workflows/ler_ms` folder to download driver data, forecasts, and scores from Zenodo

4.  Run `04_ManuscriptPlots.R` script in the `workflows/ler_ms` folder to reproduce manuscript and supplemental figures

# Instructions to reproduce FLARE forecasts and scores:

1.  Run `install_packages.R` in the `workflows/ler_ms` folder to download the LER and FLARE packages and their dependencies

2.  Run `01a_Run_FLARE-LER_forecasts.R` in the `workflows/ler_ms` folder to iteratively generate forecasts from the process LER models within FLARE for every forecast date in the forecast period

    **Note** Running weekly forecasts for two years and all three models will take \> 4-5 days.

3. Run `01b_Run_baseline_forecasts.R` in the `workflows/ler_ms` to generate the baseline empirical models and write the individual model forecasts to a parquet database

4. Run `02_GenerateEnsembles.R` in the `workflows/ler_ms` to generate the two multi-model ensemble forecasts

5. Run `03_ScoreForecasts.R` in the `workflows/ler_ms` to score the baseline and multi-model ensemble forecasts and calculate the shadowing time for all the forecasts

6. Run `04_ManuscriptPlots.R` script in the `workflows/ler_ms` folder to reproduce manuscript and supplemental figures

# Instructions for reproducing using Docker

1. Download and install Docker to your computer (https://www.docker.com)

2. At the command line, run `docker run --rm -ti -e PASSWORD=yourpassword -p 8787:8787 olssonf/olsson_et_al:latest`

3. Open a webbrowser and enter `http://localhost:8787`.  You will see an Rstudio login screen.  The user name is `rstudio` and the password is `yourpassword`

4. In the Rstudio session:  File -> Open project -> select FCRE-forecast-code/FCRE-forecast-code.Rproj

6. Follow the instructions above for reproducing the figures or the forecasts (**note: the R packages are already installed in the Docker container so `install.R` does not need to be run**)
