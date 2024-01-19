library(tidyverse)
library(lubridate)
set.seed(201)


.libPaths("/usr/local/lib/R/site-library")

#system2("ldd", args = "/usr/local/lib/R/site-library/GLM3r/exec/nixglm")

#.libPaths()

experiments <- c("daily", "daily_manual", "no_da") #, "no_da_pars", "weekly",  "monthly", "daily_no_pars"
#experiments <- c("weekly", "monthly")
#experiments <- c("daily") #"daily_no_pars",
#experiments <- c("monthly","fortnightly", "daily_no_pars")
#experiments <- "daily"

options(future.globals.maxSize = 891289600)

lake_directory <- here::here()

starting_index <- 160
use_s3 <- FALSE

files.sources <- list.files(file.path(lake_directory, "R"), full.names = TRUE)
sapply(files.sources, source)


config_set_name <- "glm_aed_ms1"
site <- "fcre"
configure_run_file <- "configure_aed_run.yml"
#config_files <- "configure_flare_glm_aed.yml"

num_forecasts <- 52 * 2
days_between_forecasts <- 7
forecast_horizon <- 35
starting_date <- as_date("2020-08-01")
second_date <- as_date("2021-01-01")


all_dates <- seq.Date(starting_date,second_date + days(days_between_forecasts * num_forecasts), by = 1)

potential_date_list <- list(daily = all_dates,
                            no_da = starting_date,
                            weekly = all_dates[seq(1,length(all_dates),by=7)],
                            fortnightly = all_dates[seq(1,length(all_dates),by=14)],
                            monthly = all_dates[seq(1,length(all_dates),by=28)],
                            no_da_pars = starting_date,
                            daily_no_pars = all_dates,
                            daily_no_pars_2 = all_dates,
                            daily_manual = all_dates)

date_list <- potential_date_list[which(names(potential_date_list) %in% experiments)]

models <- names(date_list)

start_dates <- as_date(rep(NA, num_forecasts + 1))
end_dates <- as_date(rep(NA, num_forecasts + 1))
start_dates[1] <- starting_date
end_dates[1] <- second_date
for(i in 2:(num_forecasts+1)){
  start_dates[i] <- as_date(end_dates[i-1])
  end_dates[i] <- start_dates[i] + days(days_between_forecasts)
}

sims <- expand.grid(paste0(start_dates,"_",end_dates,"_", forecast_horizon), models)

names(sims) <- c("date","model")

sims$start_dates <- stringr::str_split_fixed(sims$date, "_", 3)[,1]
sims$end_dates <- stringr::str_split_fixed(sims$date, "_", 3)[,2]
sims$horizon <- stringr::str_split_fixed(sims$date, "_", 3)[,3]

sims <- sims |>
  mutate(model = as.character(model)) |>
  select(-date) |>
  distinct_all() |>
  arrange(start_dates)

sims$horizon[1:length(models)] <- 0

# Set up configurations for the data processing
config_obs <- FLAREr::initialize_obs_processing(lake_directory, observation_yml = "observation_processing.yml", config_set_name = config_set_name)

#' Clone or pull from data repositories

FLAREr::get_git_repo(lake_directory,
                     directory = config_obs$realtime_insitu_location,
                     git_repo = "https://github.com/FLARE-forecast/FCRE-data.git")

FLAREr::get_git_repo(lake_directory,
                     directory = config_obs$realtime_met_station_location,
                     git_repo = "https://github.com/FLARE-forecast/FCRE-data.git")

FLAREr::get_git_repo(lake_directory,
                     directory = config_obs$realtime_inflow_data_location,
                     git_repo = "https://github.com/FLARE-forecast/FCRE-data.git")

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/389/7/02d36541de9088f2dd99d79dc3a7a853",
                     file = config_obs$met_raw_obs_fname[2],
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/271/7/71e6b946b751aa1b966ab5653b01077f",
                     file = config_obs$insitu_obs_fname[2],
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/198/11/81f396b3e910d3359907b7264e689052",
                     file = config_obs$secchi_fname,
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/200/13/27ceda6bc7fdec2e7d79a6e4fe16ffdf",
                     file = config_obs$ctd_fname,
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/199/11/509f39850b6f95628d10889d66885b76",
                     file = config_obs$nutrients_fname,
                     lake_directory)


FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/202/9/c065ff822e73c747f378efe47f5af12b",
                     file = config_obs$inflow_raw_file1[2],
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/542/1/791ec9ca0f1cb9361fa6a03fae8dfc95",
                     file = "silica_master_df.csv",
                     lake_directory)

FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/551/7/38d72673295864956cccd6bbba99a1a3",
                     file = "Dissolved_CO2_CH4_Virginia_Reservoirs.csv",
                     lake_directory)


#' Clean up observed meterology

cleaned_met_file <- met_data_bind(realtime_file = file.path(config_obs$file_path$data_directory, config_obs$met_raw_obs_fname[1]),
                                  qaqc_file = file.path(config_obs$file_path$data_directory, config_obs$met_raw_obs_fname[2]),
                                  cleaned_met_file = file.path(config_obs$file_path$targets_directory, config_obs$site_id,paste0("observed-met_",config_obs$site_id,".csv")),
                                  input_file_tz = "EST",
                                  nldas = NULL,
                                  site_id = config_obs$site_id)

#' Clean up observed inflow

cleaned_inflow_file <- inflow_data_combine(realtime_file = file.path(config_obs$file_path$data_directory, config_obs$inflow_raw_file1[1]),
                                           qaqc_file = file.path(config_obs$file_path$data_directory, config_obs$inflow_raw_file1[2]),
                                           nutrients_file = file.path(config_obs$file_path$data_directory, config_obs$nutrients_fname),
                                           silica_file = file.path(config_obs$file_path$data_directory,  config_obs$silica_fname),
                                           co2_ch4 = file.path(config_obs$file_path$data_directory, config_obs$ch4_fname),
                                           cleaned_inflow_file = file.path(config_obs$file_path$targets_directory, config_obs$site_id, paste0(config_obs$site_id,"-targets-inflow.csv")),
                                           input_file_tz = 'EST',
                                           site_id = config_obs$site_id)

#read_csv(cleaned_inflow_file) |>
#  mutate(observation = ifelse(variable == "PHS_frp", observation * 100, observation)) |>
#  write_csv(cleaned_inflow_file)

#' Clean up observed insitu measurements

cleaned_insitu_file <- in_situ_qaqc_csv(insitu_obs_fname = file.path(config_obs$file_path$data_directory,config_obs$insitu_obs_fname),
                                        data_location = config_obs$file_path$data_directory,
                                        maintenance_file = file.path(config_obs$file_path$data_directory,config_obs$maintenance_file),
                                        ctd_fname = file.path(config_obs$file_path$data_directory, config_obs$ctd_fname),
                                        nutrients_fname =  file.path(config_obs$file_path$data_directory, config_obs$nutrients_fname),
                                        secchi_fname = file.path(config_obs$file_path$data_directory, config_obs$secchi_fname),
                                        ch4_fname = file.path(config_obs$file_path$data_directory, config_obs$ch4_fname),
                                        cleaned_insitu_file = file.path(config_obs$file_path$targets_directory, config_obs$site_id, paste0(config_obs$site_id,"-targets-insitu.csv")),
                                        lake_name_code = config_obs$site_id,
                                        config = config_obs)

read_csv(cleaned_insitu_file) |>
  filter((variable %in% c("NH4", "NO3NO2", "SRP", "TN", "TP") & depth == 1.5) |
           variable %in% c("temperature", "oxygen", "secchi", "chla", "fdom")) |>
  write_csv(cleaned_insitu_file)


for(i in starting_index:nrow(sims)){


  config_files <- "configure_flare_glm_aed_3groups_manual.yml"


  message(paste0("index: ", i))
  message(paste0("     Running model: ", sims$model[i], " "))

  model <- sims$model[i]
  sim_names <- paste0("glmaed_ms_" ,model)

  config <- FLAREr::set_configuration(configure_run_file,lake_directory, config_set_name = config_set_name, sim_name = sim_names)

  file.copy(file.path(config$file_path$data_directory,"FCR_SSS_inflow_2013_2021_20220413_allfractions_2DOCpools.csv"),
            file.path(config$file_path$execute_directory,"FCR_SSS_inflow_2013_2021_20220413_allfractions_2DOCpools.csv"))

  if(file.exists(file.path(lake_directory, "restart", site, sim_names, configure_run_file))){
    unlink(file.path(lake_directory, "restart", site, sim_names, configure_run_file))
    if(use_s3){
      FLAREr::delete_restart(site_id = site,
                             sim_name = sim_names,
                             bucket = config$s3$warm_start$bucket,
                             endpoint = config$s3$warm_start$endpoint)
    }
  }

  run_config <- yaml::read_yaml(file.path(lake_directory, "configuration", config_set_name, configure_run_file))
  run_config$configure_flare <- config_files
  run_config$sim_name <- sim_names
  yaml::write_yaml(run_config, file = file.path(lake_directory, "restart", site, sim_names, configure_run_file))
  config <- FLAREr::set_configuration(configure_run_file,lake_directory, config_set_name = config_set_name)
  config$run_config$start_datetime <- as.character(paste0(sims$start_dates[i], " 00:00:00"))
  config$run_config$forecast_start_datetime <- as.character(paste0(sims$end_dates[i], " 00:00:00"))
  config$run_config$forecast_horizon <- as.numeric(sims$horizon[i])
  config$run_config$configure_flare <- config_files
  config$run_config$sim_name <- sim_names
  if(i <= length(models)){
    config$run_config$restart_file <- NA
  }else{
    config$run_config$restart_file <- paste0(config$location$site_id, "-", lubridate::as_date(config$run_config$start_datetime), "-", sim_names, ".nc")
    if(!file.exists(config$run_config$restart_file )){
      warning(paste0("restart file: ", config$run_config$restart_file, " doesn't exist"))
    }
  }

  run_config <- config$run_config
  yaml::write_yaml(run_config, file = file.path(lake_directory, "restart", site, sim_names, configure_run_file))
  yaml::write_yaml(run_config, file = file.path(lake_directory,"configuration",config_set_name,configure_run_file))

  config <- FLAREr::set_configuration(configure_run_file = configure_run_file ,lake_directory = lake_directory, config_set_name = config_set_name, sim_name = sim_names)
  config$model_settings$model <- model
  config$run_config$sim_name <- sim_names
  config <- FLAREr::get_restart_file(config, lake_directory)

  #if(model == "daily_no_pars_2"){
  #  pars_config <- readr::read_csv(file.path(config$file_path$configuration_directory, "parameter_calibration_config_aed_2.csv"), col_types = readr::cols())
  #}else{
    #pars_config <- readr::read_csv(file.path(config$file_path$configuration_directory, config$model_settings$par_config_file), col_types = readr::cols())
  #}

  pars_config <- NULL

  obs_config <- readr::read_csv(file.path(config$file_path$configuration_directory, config$model_settings$obs_config_file), col_types = readr::cols())
  states_config <- readr::read_csv(file.path(config$file_path$configuration_directory, config$model_settings$states_config_file), col_types = readr::cols())


  met_out <- FLAREr::generate_met_files_arrow(obs_met_file = file.path(config$file_path$qaqc_data_directory, paste0("observed-met_",config$location$site_id,".csv")),
                                              out_dir = config$file_path$execute_directory,
                                              start_datetime = config$run_config$start_datetime,
                                              end_datetime = config$run_config$end_datetime,
                                              forecast_start_datetime = config$run_config$forecast_start_datetime,
                                              forecast_horizon =  config$run_config$forecast_horizon,
                                              site_id = config$location$site_id,
                                              use_s3 = TRUE,
                                              bucket = config$s3$drivers$bucket,
                                              endpoint = config$s3$drivers$endpoint,
                                              local_directory = NULL,
                                              use_forecast = config$met$use_forecasted_met,
                                              use_siteid_s3 = FALSE)

  ## manipulate code to only include one met ensemble member - REMOVE LATER
  #met_out$filenames <- met_out$filenames[1]

  if(config$model_settings$model_name == "glm_aed"){
    variables <- c("time", "FLOW", "TEMP", "SALT",
                   'OXY_oxy',
                   'CAR_dic',
                   'CAR_ch4',
                   'SIL_rsi',
                   'NIT_amm',
                   'NIT_nit',
                   'PHS_frp',
                   'OGM_doc',
                   'OGM_docr',
                   'OGM_poc',
                   'OGM_don',
                   'OGM_donr',
                   'OGM_pon',
                   'OGM_dop',
                   'OGM_dopr',
                   'OGM_pop',
                   'PHY_cyano',
                   'PHY_green',
                   'PHY_diatom')
  }else{
    variables <- c("time", "FLOW", "TEMP", "SALT")
  }

  if(config$run_config$forecast_horizon > 0){
    inflow_forecast_dir = file.path(config$inflow$forecast_inflow_model, config$location$site_id, "0", lubridate::as_date(config$run_config$forecast_start_datetime))
  }else{
    inflow_forecast_dir <- NULL
  }

  inflow_outflow_files <- FLAREr::create_inflow_outflow_files_arrow(inflow_forecast_dir = NULL,
                                                                    inflow_obs = file.path(config$file_path$qaqc_data_directory, paste0(config$location$site_id, "-targets-inflow.csv")),
                                                                    variables = variables,
                                                                    out_dir = config$file_path$execute_directory,
                                                                    start_datetime = config$run_config$start_datetime,
                                                                    end_datetime = config$run_config$end_datetime,
                                                                    forecast_start_datetime = config$run_config$forecast_start_datetime,
                                                                    forecast_horizon =  config$run_config$forecast_horizon,
                                                                    site_id = config$location$site_id,
                                                                    use_s3 = use_s3,
                                                                    bucket = config$s3$inflow_drivers$bucket,
                                                                    endpoint = config$s3$inflow_drivers$endpoint,
                                                                    local_directory = file.path(lake_directory, "drivers", inflow_forecast_dir),
                                                                    use_forecast = FALSE,
                                                                    use_ler_vars = FALSE)

  if(config$model_settings$model_name == "glm_aed"){
    inflow_outflow_files$inflow_file_name <- cbind(inflow_outflow_files$inflow_file_name, rep(file.path(config$file_path$execute_directory,"FCR_SSS_inflow_2013_2021_20220413_allfractions_2DOCpools.csv"), length(inflow_outflow_files$inflow_file_name)))
  }

  #Create observation matrix
  obs <- FLAREr::create_obs_matrix(cleaned_observations_file_long = file.path(config$file_path$qaqc_data_directory,paste0(config$location$site_id, "-targets-insitu.csv")),
                                   obs_config = obs_config,
                                   config)


  full_time <- seq(lubridate::as_datetime(config$run_config$start_datetime), lubridate::as_datetime(config$run_config$forecast_start_datetime) + lubridate::days(config$run_config$forecast_horizon), by = "1 day")
  full_time <- as.Date(full_time)

  da_freq <- which(names(date_list) == sims$model[i])
  idx <- which(!full_time %in% date_list[[da_freq]])
  obs[, idx, ] <- NA

  if(sims$model[i] != "daily_manual"){
    idx <- which(obs_config$state_names_obs %in% c("NIT_amm","NIT_nit","NIT_total","PHS_frp","PHS_total"))
    obs[idx, , ] <- NA
  }

  obs_secchi_depth <- get_obs_secchi_depth(obs_file = file.path(config$file_path$qaqc_data_directory,paste0(config$location$site_id, "-targets-insitu.csv")),
                                           start_datetime = config$run_config$start_datetime,
                                           end_datetime = config$run_config$end_datetime,
                                           forecast_start_datetime = config$run_config$forecast_start_datetime,
                                           forecast_horizon =  config$run_config$forecast_horizon,
                                           secchi_sd = 0.1)

  obs_secchi_depth$obs_depth[] <- NA
  obs_secchi_depth$obs_secchi$obs[] <- NA

  states_config <- FLAREr::generate_states_to_obs_mapping(states_config, obs_config)

  model_sd <- FLAREr::initiate_model_error(config, states_config)

  init <- FLAREr::generate_initial_conditions(states_config,
                                              obs_config,
                                              pars_config,
                                              obs,
                                              config,
                                              historical_met_error = met_out$historical_met_error)
  #Run EnKF
  da_forecast_output <- FLAREr::run_da_forecast(states_init = init$states,
                                                pars_init = init$pars,
                                                aux_states_init = init$aux_states_init,
                                                obs = obs,
                                                obs_sd = obs_config$obs_sd,
                                                model_sd = model_sd,
                                                working_directory = config$file_path$execute_directory,
                                                met_file_names = met_out$filenames,
                                                inflow_file_names = inflow_outflow_files$inflow_file_name[,1],
                                                outflow_file_names = inflow_outflow_files$outflow_file_name,
                                                config = config,
                                                pars_config = pars_config,
                                                states_config = states_config,
                                                obs_config = obs_config,
                                                management = NULL,
                                                da_method = config$da_setup$da_method,
                                                par_fit_method = config$da_setup$par_fit_method,
                                                obs_secchi = obs_secchi_depth$obs_secchi,
                                                obs_depth = obs_secchi_depth$obs_depth)

  # Save forecast

  saved_file <- FLAREr::write_forecast_netcdf(da_forecast_output = da_forecast_output,
                                              forecast_output_directory = config$file_path$forecast_output_directory,
                                              use_short_filename = TRUE)

  forecast_df <- FLAREr::write_forecast_arrow(da_forecast_output = da_forecast_output,
                                              use_s3 = use_s3,
                                              bucket = config$s3$forecasts_parquet$bucket,
                                              endpoint = config$s3$forecasts_parquet$endpoint,
                                              local_directory = file.path(lake_directory, "forecasts/parquet"))

  rm(da_forecast_output)
  gc()

  FLAREr::generate_forecast_score_arrow(targets_file = file.path(config$file_path$qaqc_data_directory,paste0(config$location$site_id, "-targets-insitu.csv")),
                                        forecast_df = forecast_df,
                                        use_s3 = use_s3,
                                        bucket = config$s3$scores$bucket,
                                        endpoint = config$s3$scores$endpoint,
                                        local_directory = file.path(lake_directory, "scores/parquet"),
                                        variable_type = c("state","parameter","diagnostic"))

  rm(forecast_df)
  gc()

  #message("Generating plot")
  #FLAREr::plotting_general_2(file_name = saved_file,
  #                           target_file = file.path(config$file_path$qaqc_data_directory, paste0(config$location$site_id, "-targets-insitu.csv")),
  #                           ncore = 2,
  #                           obs_csv = FALSE)

  #for (itm in ls()) {
  #  print(formatC(c(itm, format(object.size(get(itm)), units = "MiB")),
  #                format="d",
  #                big.mark=",",
  #                width=30),
  #        quote=F)
  #}

  FLAREr::put_forecast(saved_file, eml_file_name = NULL, config)

  FLAREr::update_run_config(config, lake_directory, configure_run_file, saved_file, new_horizon = forecast_horizon, day_advance = days_between_forecasts)
}
