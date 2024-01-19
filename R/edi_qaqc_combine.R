wq_realtime_edi_combine <- function(realtime_file,
                               qaqc_file,
                               config,
                               input_file_tz){


  #config <- config_file
  #config <- read_yaml(config_file)
  # realtime_file = L1 FILE STORED ON GITHUB
  # qaqc_file = EXISTING FILE STORED ON EDI

  d1 <- read.csv(realtime_file, na.strings = 'NA', stringsAsFactors = FALSE)
  #d1 <- realtime_file

  #salt_quantiles <- quantile(((0.001 * d1$EXOSpCond_uScm_1) ^ 1.08), c(0.0025,0.975), na.rm = TRUE)

  # d1 <- d1 |>
  #   dplyr::mutate(salt = (0.001 * d1$EXOSpCond_uScm_1) ^ 1.08) |>
  #   dplyr::mutate(salt = ifelse(salt < salt_quantiles[1] | salt > salt_quantiles[2], NA, salt))

  if(!is.na(qaqc_file)){
  #if(edi_exist == TRUE){
    #Different lakes are going to have to modify this for their temperature data format
    #d1 <- realtime_file

    d2 <- read.csv(qaqc_file, na.strings = 'NA', stringsAsFactors = FALSE)
    #d2 <- qaqc_file

    TIMESTAMP_in <- as_datetime(d1$DateTime,tz = input_file_tz)
    d1$TIMESTAMP <- with_tz(TIMESTAMP_in,tz = "UTC")

    TIMESTAMP_in <- as_datetime(d2$DateTime,tz = input_file_tz)
    d2$TIMESTAMP <- with_tz(TIMESTAMP_in,tz = "UTC")


    d1 <- d1 %>%
      dplyr::mutate(Depth_m = LvlPressure_psi_9 * 0.70455,
                    Depth_m = ifelse(Depth_m < 8, NA, Depth_m))
    d2 <- d2 %>%
      dplyr::mutate(Depth_m = LvlPressure_psi_9 * 0.70455,
                    Depth_m = ifelse(Depth_m < 8, NA, Depth_m))

    # d2 <- d2 |>
    #   dplyr::mutate(salt = (0.001 * EXOSpCond_uScm_1) ^ 1.08) |>
    #   dplyr::mutate(salt = ifelse(salt < salt_quantiles[1] | salt > salt_quantiles[2], NA, salt))



    #d1 <- d1[which(d1$TIMESTAMP > d2$TIMESTAMP[nrow(d2)] | d1$TIMESTAMP < d2$TIMESTAMP[1]), ]

    #d3 <- data.frame(TIMESTAMP = d1$TIMESTAMP, wtr_surface = d1$wtr_surface, wtr_1 = d1$wtr_1, wtr_2 = d1$wtr_2, wtr_3 = d1$wtr_3, wtr_4 = d1$wtr_4,
    #                 wtr_5 = d1$wtr_5, wtr_6 = d1$wtr_6, wtr_7 = d1$wtr_7, wtr_8 = d1$wtr_8, wtr_9 = d1$wtr_9, wtr_1_exo = d1$EXO_wtr_1, wtr_5_do = d1$dotemp_5, wtr_9_do = d1$dotemp_9)

    d3 <-  data.frame(TIMESTAMP = d1$TIMESTAMP, wtr_surface = d1$ThermistorTemp_C_surface,
                      wtr_1 = d1$ThermistorTemp_C_1, wtr_2 = d1$ThermistorTemp_C_2,
                      wtr_3 = d1$ThermistorTemp_C_3, wtr_4 = d1$ThermistorTemp_C_4,
                      wtr_5 = d1$ThermistorTemp_C_5, wtr_6 = d1$ThermistorTemp_C_6,
                      wtr_7 = d1$ThermistorTemp_C_7, wtr_8 = d1$ThermistorTemp_C_8,
                      wtr_9 = d1$ThermistorTemp_C_9, wtr_1_exo = d1$EXOTemp_C_1,
                      wtr_5_do = d1$RDOTemp_C_5, wtr_9_do = d1$RDOTemp_C_9,
                      Chla_1 = d1$EXOChla_ugL_1, doobs_1 = d1$EXODO_mgL_1,
                      doobs_5 = d1$RDO_mgL_5, doobs_9 = d1$RDO_mgL_9,
                      fDOM_1 = d1$EXOfDOM_QSU_1, bgapc_1 = d1$EXOBGAPC_ugL_1,
                      depth_1.6 = d1$EXODepth_m, Depth_m = d1$Depth_m, spec_cond = d1$EXOSpCond_uScm_1)

    d4 <- data.frame(TIMESTAMP = d2$TIMESTAMP, wtr_surface = d2$ThermistorTemp_C_surface,
                     wtr_1 = d2$ThermistorTemp_C_1, wtr_2 = d2$ThermistorTemp_C_2,
                     wtr_3 = d2$ThermistorTemp_C_3, wtr_4 = d2$ThermistorTemp_C_4,
                     wtr_5 = d2$ThermistorTemp_C_5, wtr_6 = d2$ThermistorTemp_C_6,
                     wtr_7 = d2$ThermistorTemp_C_7, wtr_8 = d2$ThermistorTemp_C_8,
                     wtr_9 = d2$ThermistorTemp_C_9, wtr_1_exo = d2$EXOTemp_C_1,
                     wtr_5_do = d2$RDOTemp_C_5, wtr_9_do = d2$RDOTemp_C_9,
                     Chla_1 = d2$EXOChla_ugL_1, doobs_1 = d2$EXODO_mgL_1,
                     doobs_5 = d2$RDO_mgL_5, doobs_9 = d2$RDO_mgL_9,
                     fDOM_1 = d2$EXOfDOM_QSU_1, bgapc_1 = d2$EXOBGAPC_ugL_1,
                     depth_1.6 = d2$EXODepth_m, Depth_m = d2$Depth_m, spec_cond = d2$EXOSpCond_uScm_1)

    d <- rbind(d3,d4)

  }else{
    #Different lakes are going to have to modify this for their temperature data format
    d1 <- realtime_file

    TIMESTAMP_in <- as_datetime(d1$DateTime,tz = input_file_tz)
    d1$TIMESTAMP <- with_tz(TIMESTAMP_in,tz = "UTC")

    d <-  data.frame(TIMESTAMP = d1$TIMESTAMP, wtr_surface = d1$ThermistorTemp_C_surface,
                     wtr_1 = d1$ThermistorTemp_C_1, wtr_2 = d1$ThermistorTemp_C_2,
                     wtr_3 = d1$ThermistorTemp_C_3, wtr_4 = d1$ThermistorTemp_C_4,
                     wtr_5 = d1$ThermistorTemp_C_5, wtr_6 = d1$ThermistorTemp_C_6,
                     wtr_7 = d1$ThermistorTemp_C_7, wtr_8 = d1$ThermistorTemp_C_8,
                     wtr_9 = d1$ThermistorTemp_C_9, wtr_1_exo = d1$EXOTemp_C_1,
                     wtr_5_do = d1$RDOTemp_C_5, wtr_9_do = d1$RDOTemp_C_9,
                     Chla_1 = d1$EXOChla_ugL_1, doobs_1 = d1$EXODO_mgL_1,
                     doobs_5 = d1$RDO_mgL_5, doobs_9 = d1$RDO_mgL_9,
                     fDOM_1 = d1$EXOfDOM_QSU_1, bgapc_1 = d1$EXOBGAPC_ugL_1,
                     depth_1.6 = d1$EXO_depth, Depth_m = d1$Depth_m, spec_cond = d1$EXOSpCond_uScm_1)
  }


  salt_quantiles <- quantile(((0.001 * d$spec_cond) ^ 1.08), c(0.0025,0.975), na.rm = TRUE)

  d <- d |>
    dplyr::mutate(salt = (0.001 * spec_cond) ^ 1.08) |>
    dplyr::mutate(salt = ifelse(salt < salt_quantiles[1] | salt > salt_quantiles[2], NA, salt)) |>
    select(-spec_cond)

  d$fDOM_1 <- config$exo_sensor_2_grab_sample_fdom[1] + config$exo_sensor_2_grab_sample_fdom[2] * d$fDOM_1

  #oxygen unit conversion
  d$doobs_1 <- d$doobs_1*1000/32  #mg/L (obs units) -> mmol/m3 (glm units)
  d$doobs_5 <- d$doobs_5*1000/32  #mg/L (obs units) -> mmol/m3 (glm units)
  d$doobs_9 <- d$doobs_9*1000/32  #mg/L (obs units) -> mmol/m3 (glm units)

  d$Chla_1 <-  config$exo_sensor_2_ctd_chla[1] +  d$Chla_1 *  config$exo_sensor_2_ctd_chla[2]
  d$doobs_1 <- config$exo_sensor_2_ctd_do[1]  +   d$doobs_1 * config$exo_sensor_2_ctd_do[2]
  d$doobs_5 <- config$do_sensor_2_ctd_do_5[1] +   d$doobs_5 * config$do_sensor_2_ctd_do_5[2]
  d$doobs_9 <- config$do_sensor_2_ctd_do_9[1] +   d$doobs_9 * config$do_sensor_2_ctd_do_9[2]

  d <- d %>%
    dplyr::mutate(day = lubridate::day(TIMESTAMP),
                  year = lubridate::year(TIMESTAMP),
                  hour = lubridate::hour(TIMESTAMP),
                  month = lubridate::month(TIMESTAMP)) %>%
    dplyr::group_by(day, year, hour, month) %>%
    dplyr::select(-TIMESTAMP) %>%
    dplyr::summarise_all(mean, na.rm = TRUE) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(day = as.numeric(day),
                  hour = as.numeric(hour)) %>%
    dplyr::mutate(day = ifelse(as.numeric(day) < 10, paste0("0",day),day),
                  hour = ifelse(as.numeric(hour) < 10, paste0("0",hour),hour)) %>%
    dplyr::mutate(timestamp = as_datetime(paste0(year,"-",month,"-",day," ",hour,":00:00"),tz = "UTC")) %>%
    dplyr::arrange(timestamp)


  d_therm <- d %>%
    dplyr::select(timestamp, wtr_surface, wtr_1, wtr_2, wtr_3, wtr_4, wtr_5, wtr_6,
                  wtr_7,wtr_8, wtr_9) %>%
    dplyr::rename("0.0" = wtr_surface,
                  "1.0" = wtr_1,
                  "2.0" = wtr_2,
                  "3.0" = wtr_3,
                  "4.0" = wtr_4,
                  "5.0" = wtr_5,
                  "6.0" = wtr_6,
                  "7.0" = wtr_7,
                  "8.0" = wtr_8,
                  "9.0" = wtr_9) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "temperature",
                  method = "thermistor",
                  observed = ifelse(is.nan(observed), NA, observed))


  d_do_temp <- d %>%
    dplyr::select(timestamp, wtr_5_do, wtr_9_do) %>%
    dplyr::rename("5.0" = wtr_5_do,
                  "9.0" = wtr_9_do) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "temperature",
                  method = "do_sensor",
                  observed = ifelse(is.nan(observed), NA, observed))

  d_exo_temp <- d %>%
    dplyr::select(timestamp, wtr_1_exo) %>%
    dplyr::rename("1.6" = wtr_1_exo) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    mutate(variable = "temperature",
           method = "exo_sensor",
           observed = ifelse(is.nan(observed), NA, observed))

  d_do_do <- d %>%
    dplyr::select(timestamp, doobs_5, doobs_9) %>%
    dplyr::rename("5.0" = doobs_5,
                  "9.0" = doobs_9) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "oxygen",
                  method = "do_sensor",
                  observed = ifelse(is.nan(observed), NA, observed))

  d_exo_do <- d %>%
    dplyr::select(timestamp, doobs_1) %>%
    dplyr::rename("1.6" = doobs_1) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "oxygen",
                  method = "exo_sensor",
                  observed = ifelse(is.nan(observed), NA, observed))

  d_exo_fdom <- d %>%
    dplyr::select(timestamp, fDOM_1) %>%
    dplyr::rename("1.6" = fDOM_1) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "fdom",
                  method = "exo_sensor",
                  observed = ifelse(is.nan(observed), NA, observed))

  d_exo_chla <- d %>%
    dplyr::select(timestamp, Chla_1) %>%
    dplyr::rename("1.6" = Chla_1) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "chla",
                  method = "exo_sensor",
                  observed = ifelse(is.nan(observed), NA, observed))

  d_exo_bgapc <- d %>%
    dplyr::select(timestamp, bgapc_1) %>%
    dplyr::rename("1.6" = bgapc_1) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "bgapc",
                  method = "exo_sensor",
                  observed = ifelse(is.nan(observed), NA, observed))

  d_exo_salt <- d %>%
    dplyr::select(timestamp, salt) %>%
    dplyr::rename("1.6" = salt) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(variable = "salt",
                  method = "exo_sensor",
                  observed = ifelse(is.nan(observed), NA, observed))


  d_depth <- d %>%
    dplyr::select(timestamp, Depth_m) %>%
    tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "observed") %>%
    dplyr::mutate(depth = NA) %>%
    dplyr::mutate(variable = "depth",
                  method = "pres_trans",
                  observed = ifelse(is.nan(observed), NA, observed))

  if(config$variable_obsevation_depths == TRUE){

    d_depth <- d %>% dplyr::mutate(wtr_surface = depth_1.6 - 0.6 - 0.9,
                                   wtr_1 = depth_1.6 - 0.6,
                                   wtr_2 = depth_1.6 + 0.4,
                                   wtr_3 = depth_1.6 + 1.4,
                                   wtr_4 = depth_1.6 + 2.4,
                                   wtr_5 = depth_1.6 + 3.4,
                                   wtr_6 = depth_1.6 + 4.4,
                                   wtr_7 = depth_1.6 + 5.4,
                                   wtr_8 = depth_1.6 + 6.4,
                                   wtr_9 = depth_1.6 + 7.4,
                                   wtr_1_exo = depth_1.6,
                                   wtr_5_do = depth_1.6 + 3.4,
                                   wtr_9_do = depth_1.6 + 7.4,
                                   Chla_1 = depth_1.6,
                                   doobs_1 = depth_1.6 - 0.6,
                                   doobs_5 = depth_1.6 + 3.4,
                                   doobs_9 = depth_1.6 + 7.4,
                                   fDOM_1 = depth_1.6,
                                   bgapc_1 = depth_1.6) %>%
      dplyr::select(-c(depth_1.6, day,year, hour, month))


    d_therm_depth <- d_depth %>%
      dplyr::select(timestamp, wtr_surface, wtr_1, wtr_2, wtr_3, wtr_4, wtr_5, wtr_6,
                    wtr_7,wtr_8, wtr_9) %>%
      dplyr::rename("0.0" = wtr_surface,
                    "1.0" = wtr_1,
                    "2.0" = wtr_2,
                    "3.0" = wtr_3,
                    "4.0" = wtr_4,
                    "5.0" = wtr_5,
                    "6.0" = wtr_6,
                    "7.0" = wtr_7,
                    "8.0" = wtr_8,
                    "9.0" = wtr_9) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "temperature",
                    method = "thermistor",
                    depth_exo = ifelse(is.nan(depth_exo), NA, depth_exo))

    d_therm <- d_therm %>%
      dplyr::left_join(d_therm_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

    d_do_temp_depth <- d_depth %>%
      dplyr::select(timestamp, wtr_5_do, wtr_9_do) %>%
      dplyr::rename("5.0" = wtr_5_do,
                    "9.0" = wtr_9_do) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "temperature",
                    method = "do_sensor")

    d_do_temp <- d_do_temp %>%
      dplyr::left_join(d_do_temp_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

    d_exo_temp_depth <- d_depth %>%
      dplyr::select(timestamp, wtr_1_exo) %>%
      dplyr::rename("1.6" = wtr_1_exo) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "temperature",
                    method = "exo_sensor")

    d_exo_temp <- d_exo_temp %>%
      dplyr::left_join(d_do_temp_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

    d_do_do_depth <- d_depth %>%
      dplyr::select(timestamp, doobs_5, doobs_9) %>%
      dplyr::rename("5.0" = doobs_5,
                    "9.0" = doobs_9) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "oxygen",
                    method = "do_sensor")

    d_do_do <- d_do_do %>%
      dplyr::left_join(d_do_do_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

    d_exo_do_depth <- d_depth %>%
      dplyr::select(timestamp, doobs_1) %>%
      dplyr::rename("1.6" = doobs_1) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "oxygen",
                    method = "exo_sensor")

    d_exo_do <- d_exo_do %>%
      dplyr::left_join(d_exo_do_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

    d_exo_fdom_depth <- d_depth %>%
      dplyr::select(timestamp, fDOM_1) %>%
      dplyr::rename("1.6" = fDOM_1) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "oxygen",
                    method = "exo_sensor")

    d_exo_fdom <- d_exo_fdom %>%
      dplyr::left_join(d_exo_fdom_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

    d_exo_chla_depth <- d_depth %>%
      dplyr::select(timestamp, Chla_1) %>%
      dplyr::rename("1.6" = Chla_1) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "chla",
                    method = "exo_sensor")

    d_exo_chla <- d_exo_chla %>%
      dplyr::left_join(d_exo_chla_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

    d_exo_bgapc_depth <- d_depth %>%
      dplyr::select(timestamp, bgapc_1) %>%
      dplyr::rename("1.6" = bgapc_1) %>%
      tidyr::pivot_longer(cols = -timestamp, names_to = "depth", values_to = "depth_exo") %>%
      dplyr::mutate(variable = "bgapc",
                    method = "exo_sensor")

    d_exo_bgapc <- d_exo_bgapc %>%
      dplyr::left_join(d_exo_chla_depth, by = c("timestamp", "depth","variable", "method")) %>%
      dplyr::mutate(depth = ifelse(!is.na(depth_exo),depth_exo,depth),
                    depth = as.numeric(depth),
                    depth = round(depth, 2)) %>%
      dplyr::select(-depth_exo) %>%
      dplyr::filter(depth > 0.0)

  }


  d <- rbind(d_therm,d_do_temp,d_exo_temp,d_do_do,d_exo_do,d_exo_fdom,
             d_exo_chla,d_exo_bgapc, d_depth, d_exo_salt)

  d <- d %>%
    dplyr::rename(time = timestamp)

  d <- d %>% dplyr::mutate(depth = as.numeric(depth))


  # write to output file
  return(d)

}
