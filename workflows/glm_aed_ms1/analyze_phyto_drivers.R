library(arrow)
library(tidyverse)
library(lubridate)
focal_ens_members <- 1:10
focal_depths <- c(0.5, 1.5, 5, 8)
#focal_reference_datetime <- "2021-08-20 00:00:00"
focal_reference_datetime <- "2021-05-07 00:00:00"

setwd("/home/rqthomas/glm-aed-sims/FCRE-forecast-code/")


scaler <-  open_dataset("forecasts/parquet/site_id=fcre") %>%
  filter(depth %in% focal_depths,
         reference_datetime == focal_reference_datetime,
         model_id %in% c("glmaed_ms_daily"),
         variable %in% c("PHY_green_fNit", "PHY_green_fPho", "PHY_green_fT")) %>%
  dplyr::select(datetime,depth, reference_datetime, model_id, variable, parameter, prediction) %>%
  collect() %>%
  #filter(datetime > reference_datetime) %>%
  pivot_wider(names_from = variable, values_from = prediction) %>%
  rowwise() %>%
  mutate(scaler = min(c(PHY_green_fNit, PHY_green_fPho)) *  PHY_green_fT,
         growth = scaler * 2,
         nut_scaler = min(c(PHY_green_fNit, PHY_green_fPho))) %>%
  pivot_longer(-c(datetime,model_id, parameter,  depth, reference_datetime), names_to = "variable", values_to = "prediction") %>%
  filter(variable %in% c("scaler","growth", "nut_scaler")) %>%
  select(datetime, reference_datetime, depth, model_id, variable, parameter, prediction)


open_dataset("forecasts/parquet/site_id=fcre") %>%
  filter(depth %in% focal_depths | is.na(depth),
         reference_datetime == focal_reference_datetime,
         #horizon >= 0,
         model_id %in% c("glmaed_ms_daily"),
         variable %in% c("chla", "PHY_green_fNit", "PHY_green_fPho", "PHY_green_fT", "NIT_amm", "NIT_nit", "PHS_frp", "secchi",
                         "R_resp", "temperature", "NH4", "NO3NO2", "SRP")) %>%
  select(datetime, reference_datetime, depth, model_id, variable, parameter, prediction) %>%
  collect() %>%
  bind_rows(scaler) %>%
  mutate(model_id = ifelse(model_id == "glmaed_ms_daily", "daily", model_id),
         model_id = ifelse(model_id == "glmaed_ms_weekly", "weekly", model_id),
         model_id = ifelse(model_id == "glmaed_ms_fortnightly", "fortnightly", model_id),
         model_id = ifelse(model_id == "glmaed_ms_monthly", "monthly", model_id),
         model_id = ifelse(model_id == "glmaed_ms_no_da", "no da", model_id),
         model_id = ifelse(model_id == "glmaed_ms_daily_no_pars", "daily no pars", model_id),
         model_id = factor(model_id, levels=c("daily","weekly","fortnightly","monthly","no da", "daily no pars", "climatology"))) %>%
  mutate(variable = ifelse(variable == "PHY_green_fNit", "fNit", variable),
         variable = ifelse(variable == "PHY_green_fPho", "fPho", variable),
         variable = ifelse(variable == "PHY_green_fT", "fT", variable),
         variable = ifelse(variable == "NH4", "amm", variable),
         variable = ifelse(variable == "NO3NO2", "nit", variable),
         variable = ifelse(variable == "SRP", "frp", variable),
         variable = ifelse(variable == "temperature", "temp", variable),
         variable = factor(variable, levels=c("fNit","fPho","nut_scaler", "fT", "scaler", "growth", "R_resp", "chla", "amm", "nit", "frp", "temp", "secchi"))) %>%
  filter(parameter %in% c(focal_ens_members)
         #datetime > reference_datetime,
         ) %>%
  ggplot(aes(x = datetime)) +
  geom_line(aes(y = prediction, color = factor(parameter))) +
  facet_grid(variable~depth, scales = "free_y") +
  theme_bw() +
  labs(x = "date time", y = "forecast") +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5,vjust = 0.5))
