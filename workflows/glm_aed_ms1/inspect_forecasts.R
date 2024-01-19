pdf(width = 12, height = 12, "forecasts.pdf")
relative_forecasts_directory <- "forecasts/parquet/site_id=fcre"
relative_scores_directory <- "scores/parquet/site_id=fcre"

ref_datetimes <- ref_datetimes[-1]

for(ref_datetime in ref_datetimes){


  obs <- open_dataset(relative_scores_directory) %>%
    filter(depth == 1.5,
           reference_datetime == ref_datetime,
           #horizon >= 0,
           model_id %in% c("glmaed_ms_daily"),
           variable %in% c("temperature", "oxygen", "fdom", "chla")) %>%
    select(datetime, variable, observation) %>%
    distinct() %>%
    collect()

  total_n <-  open_dataset(relative_forecasts_directory) %>%
    filter(depth == 1.5,
           reference_datetime == ref_datetime,
           model_id %in% c("glmaed_ms_daily", "glmaed_ms_no_da"),
           variable %in% c("NH4", "NO3NO2")) %>%
    dplyr::select(datetime, reference_datetime, model_id, variable, parameter, prediction) %>%
    collect() %>%
    filter(datetime > reference_datetime) %>%
    mutate(model_id = ifelse(model_id == "glmaed_ms_daily", "daily", model_id),
           model_id = ifelse(model_id == "glmaed_ms_weekly", "weekly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_fortnightly", "fortnightly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_monthly", "monthly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_no_da", "no da", model_id),
           model_id = ifelse(model_id == "glmaed_ms_daily_no_pars", "daily no pars", model_id),
           model_id = factor(model_id, levels=c("daily","weekly","fortnightly","monthly","no da", "daily no pars", "climatology"))) %>%
    pivot_wider(names_from = variable, values_from = prediction) %>%
    rowwise() %>%
    mutate(total_n = NH4 + NO3NO2) %>%
    pivot_longer(-c(datetime,model_id, parameter, reference_datetime), names_to = "variable", values_to = "prediction") %>%
    filter(variable %in% c("total_n")) %>%
    select(datetime, reference_datetime, model_id, variable, parameter, prediction)

  scaler <-  open_dataset(relative_forecasts_directory) %>%
    filter(depth == 1.5,
           reference_datetime == ref_datetime,
           model_id %in% c("glmaed_ms_daily", "glmaed_ms_no_da"),
           variable %in% c("PHY_green_fNit", "PHY_green_fPho", "PHY_green_fT")) %>%
    dplyr::select(datetime, reference_datetime, model_id, variable, parameter, prediction) %>%
    collect() %>%
    filter(datetime > reference_datetime) %>%
    mutate(model_id = ifelse(model_id == "glmaed_ms_daily", "daily", model_id),
           model_id = ifelse(model_id == "glmaed_ms_weekly", "weekly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_fortnightly", "fortnightly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_monthly", "monthly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_no_da", "no da", model_id),
           model_id = ifelse(model_id == "glmaed_ms_daily_no_pars", "daily no pars", model_id),
           model_id = factor(model_id, levels=c("daily","weekly","fortnightly","monthly","no da", "daily no pars", "climatology"))) %>%
    pivot_wider(names_from = variable, values_from = prediction) %>%
    rowwise() %>%
    mutate(scaler = min(c(PHY_green_fNit, PHY_green_fPho)) *  PHY_green_fT,
           growth = scaler * 2) %>%
    pivot_longer(-c(datetime,model_id, parameter, reference_datetime), names_to = "variable", values_to = "prediction") %>%
    filter(variable %in% c("scaler","growth")) %>%
    select(datetime, reference_datetime, model_id, variable, parameter, prediction)

  p <- open_dataset(relative_forecasts_directory) %>%
    filter(depth == 1.5,
           reference_datetime == ref_datetime,
           #horizon >= 0,
           model_id %in% c("glmaed_ms_daily", "glmaed_ms_no_da"),
           variable %in% c("temperature", "oxygen", "fdom", "chla", "PHY_green_fNit", "PHY_green_fPho", "PHY_green_fT", "R_resp", "PHS_frp")) %>%
    select(datetime, reference_datetime, model_id, variable, parameter, prediction) %>%
    collect() %>%
    filter(datetime > reference_datetime) %>%
    mutate(model_id = ifelse(model_id == "glmaed_ms_daily", "daily", model_id),
           model_id = ifelse(model_id == "glmaed_ms_weekly", "weekly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_fortnightly", "fortnightly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_monthly", "monthly", model_id),
           model_id = ifelse(model_id == "glmaed_ms_no_da", "no da", model_id),
           model_id = ifelse(model_id == "glmaed_ms_daily_no_pars", "daily no pars", model_id),
           model_id = factor(model_id, levels=c("daily","weekly","fortnightly","monthly","no da", "daily no pars", "climatology"))) %>%
    bind_rows(scaler) %>%
    bind_rows(total_n) %>%
    left_join(y = obs, by = join_by(datetime, variable)) %>%
    ggplot(aes(x = datetime)) +
    geom_line(aes(y = prediction, group = parameter)) +
    geom_point(aes(y = observation), color = "blue") +
    facet_grid(variable~model_id, scales = "free_y") +
    theme_bw() +
    labs(x = "date time", y = "forecast", title = ref_datetime) +
    theme(axis.text.x = element_text(angle = 90, hjust = 0.5,vjust = 0.5))

  print(p)
}

dev.off()
