
library(tidyverse)
library(lubridate)

message("Beginning generate targets")
message(config_set_name)

#' Set the lake directory to the repository directory

lake_directory <- here::here()


#' Source the R files in the repository

files.sources <- list.files(file.path(lake_directory, "R"), full.names = TRUE)
sapply(files.sources, source)

# Set up configurations for the data processing
config_obs <- FLAREr::initialize_obs_processing(lake_directory, observation_yml = "observation_processing.yml", config_set_name = config_set_name)

#' Clone or pull from data repositories

FLAREr::get_git_repo(lake_directory,
                     directory = config_obs$realtime_insitu_location,
                     git_repo = "https://github.com/FLARE-forecast/FCRE-data.git")

FLAREr::get_git_repo(lake_directory,
                     directory = config_obs$realtime_met_station_location,
                     git_repo = "https://github.com/FLARE-forecast/FCRE-data.git")


#' Download files from EDI

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/389/6/a5524c686e2154ec0fd0459d46a7d1eb",
                     file = config_obs$met_raw_obs_fname[2],
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/271/6/23a191c1870a5b18cbc17f2779f719cf",
                     file = config_obs$insitu_obs_fname[2],
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/198/8/336d0a27c4ae396a75f4c07c01652985",
                     file = config_obs$secchi_fname,
                     lake_directory)


FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/202/7/f5fa5de4b49bae8373f6e7c1773b026e",
                     file = config_obs$inflow_raw_file1[2],
                     lake_directory)

#' Clean up observed meterology
cleaned_insitu_file <- in_situ_qaqc_csv(insitu_obs_fname = file.path(config_obs$file_path$data_directory,config_obs$insitu_obs_fname),
                                        data_location = config_obs$file_path$data_directory,
                                        maintenance_file = file.path(config_obs$file_path$data_directory,config_obs$maintenance_file),
                                        ctd_fname = NA,
                                        nutrients_fname =  NA,
                                        secchi_fname = NA,
                                        ch4_fname = NA,
                                        cleaned_insitu_file = file.path(config_obs$file_path$targets_directory, config_obs$site_id, paste0(config_obs$site_id,"-targets-insitu.csv")),
                                        lake_name_code = config_obs$site_id,
                                        config = config_obs)

message("Successfully generated targets")

FLAREr::put_targets(site_id = config_obs$site_id,
                    cleaned_insitu_file,
                    cleaned_met_file,
                    cleaned_inflow_file,
                    use_s3 = config$run_config$use_s3,
                    config = config)

if(config$run_config$use_s3){
  message("Successfully moved targets to s3 bucket")
}
