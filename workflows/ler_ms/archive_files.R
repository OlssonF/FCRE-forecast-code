library(arrow)
library(tidyverse)

site_id_list <- c("fcre")
model_id_list <- c("GLM",
                   "GOTM",
                   "Simstrat",
                   "RW",
                   "empirical_ler",
                   "ler",
                   "climatology")
use_s3 <- TRUE
first_date <- "2021-03-01 00:00:00"
last_date <- "2023-02-20 00:00:00"
start_date_list <- seq.Date(as.Date(first_date),as.Date(last_date), 7)


lake_directory <- here::here()

# Archiving NOAA ----------
message("Archiving stage 2 NOAA")

s3_stage2 <- s3_bucket("drivers/noaa/gefs-v12-reprocess/stage2/parquet/0", endpoint_override = "s3.flare-forecast.org", anonymous = TRUE)

df <- open_dataset(s3_stage2, partitioning = c("start_date","site_id")) |>
  filter(site_id %in% site_id_list,
         start_date %in% start_date_list)

write_dataset(df,
              path = file.path(lake_directory, "archive/drivers/drivers/noaa/gefs-v12-reprocess/stage2/parquet/0"),
              hive_style = FALSE,
              partitioning = c("start_date","site_id"))

message("Archiving stage 3 NOAA")

s3_stage3 <- s3_bucket("drivers/noaa/gefs-v12-reprocess/stage3/parquet", endpoint_override = "s3.flare-forecast.org", anonymous = TRUE)

df <- open_dataset(s3_stage3, partitioning = c("site_id")) |>
  filter(site_id %in% site_id_list)

write_dataset(df,
              path = file.path(lake_directory, "archive/drivers/drivers/noaa/gefs-v12-reprocess/stage3"),
              hive_style = FALSE,
              partitioning = c("site_id"))

setwd(file.path(lake_directory, "archive/drivers"))
files2zip <- fs::dir_ls(recurse = TRUE)
files2zip <- files2zip[stringr::str_detect(files2zip, pattern = "DS_Store", negate = TRUE)][-1]
utils::zip(zipfile = file.path(lake_directory, "archive/drivers"), files = files2zip)

##############

# Archive forecasts -----------------------
message("Archiving forecast parquets")

if(use_s3){
  s3_forecast <- arrow::s3_bucket(bucket = "forecasts/ler_ms3/parquet", endpoint_override =  "s3.flare-forecast.org", anonymous = TRUE)
}else{
  s3_forecast <- file.path(lake_directory, "forecasts/fcre/reruns/parquets/")
}

df_all <- open_dataset(s3_forecast) |>
  filter(site_id %in% site_id_list,
         model_id %in% model_id_list)

write_dataset(df_all, path = file.path(lake_directory, "archive/forecasts/forecasts"),
              hive_style = TRUE, partitioning = c("site_id","reference_datetime"))

setwd(file.path(lake_directory, "archive/forecasts"))
files2zip <- fs::dir_ls(recurse = TRUE)
files2zip <- files2zip[stringr::str_detect(files2zip, pattern = "DS_Store", negate = TRUE)][-1]
utils::zip(zipfile = file.path(lake_directory, "archive/forecasts"), files = files2zip)

#######

# Archiving scores ---------------------------
message("Archiving score parquets")

if(use_s3){
  s3_scores <- arrow::s3_bucket(bucket = "scores/ler_ms3/parquet",
                             endpoint_override =  "s3.flare-forecast.org",
                             anonymous = TRUE)
}else{
  s3_scores <- file.path(lake_directory, "scores/reruns")
}

df_all <- open_dataset(s3_scores) |>
  filter(site_id %in% site_id_list,
         model_id %in% model_id_list)

write_dataset(df_all, path = file.path(lake_directory, "archive/scores/scores/"),
              hive_style = TRUE, partitioning = c("site_id","reference_datetime"))


setwd(file.path(lake_directory, "archive/scores"))
files2zip <- fs::dir_ls(recurse = TRUE)
files2zip <- files2zip[stringr::str_detect(files2zip, pattern = "DS_Store", negate = TRUE)][-1]
utils::zip(zipfile = file.path(lake_directory, "archive/scores"), files = files2zip)

#######

# Archive targets ------------------------------
message("Archiving targets")

s3_targets <- file.path(lake_directory, "targets/")

fs::dir_create(file.path(lake_directory, "archive/targets"))

file.copy(from = s3_targets, paste0(lake_directory,"/archive/targets"),
          overwrite = TRUE, recursive = TRUE, copy.mode = TRUE)

setwd(file.path(lake_directory, "archive/targets"))
files2zip <- fs::dir_ls(recurse = TRUE)
files2zip <- files2zip[stringr::str_detect(files2zip, pattern = "DS_Store", negate = TRUE)][-1]
utils::zip(zipfile = file.path(lake_directory, "archive/targets"), files = files2zip)
