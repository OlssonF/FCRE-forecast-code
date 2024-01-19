library(tidyverse)
library(lubridate)
library(arrow)

target_file <- "targets/fcre/fcre-targets-insitu.csv"

historical_data <- read_csv(target_file)

focal_variables <- c("temperature", "oxygen", "fdom", "chla")

num_forecasts <- 52
days_between_forecasts <- 7
forecast_horizon <- 35
starting_date <- as_date("2020-08-01")
second_date <- as_date("2021-01-01")


start_dates <- as_date(rep(NA, num_forecasts + 1))
end_dates <- as_date(rep(NA, num_forecasts + 1))
start_dates[1] <- starting_date
end_dates[1] <- second_date
for(i in 2:(num_forecasts+1)){
  start_dates[i] <- as_date(end_dates[i-1])
  end_dates[i] <- start_dates[i] + days(days_between_forecasts)
}

for(i in 2:length(start_dates)){

  print(start_dates[i])

  reference_datetime <- start_dates[i]
  forecasted_dates <- seq(start_dates[i], length.out = 35, by = 1)
  forecasted_doy <- yday(forecasted_dates)

  forecast_df <- NULL

  for(j in 1:length(focal_variables)){

    print(focal_variables[j])


    obs <- historical_data %>%
      mutate(year = year(datetime)) %>%
      filter(variable == focal_variables[j],
             depth == 1.5,
             year %in% c(2019, 2020)) %>%
      mutate(doy = yday(datetime))


    lm_data <- obs %>%
      select(observation, year, doy) %>%
      pivot_wider(names_from = year, values_from = observation)

    fit <- lm(`2019` ~ `2020`, data = lm_data)

    doy_forecast <- obs %>%
      group_by(doy) %>%
      summarize(prediction = mean(observation), .groups = "drop")


    forecasts <- doy_forecast %>%
      filter(doy %in% forecasted_doy)

    prediction <- NULL
    datetime <- NULL
    parameter <- NULL
    for(k in 1:length(forecasts$prediction)){
      resid_sample <- sample(fit$residuals, size = 62, replace = TRUE)
      prediction <- c(prediction, forecasts$prediction[k] + resid_sample)
      datetime <- as_date(c(as_date(datetime), rep(forecasted_dates[k], 62)))
      parameter <- c(parameter, 1:62)
    }


    forecast_variable_df <- tibble(datetime = as_datetime(datetime),
                          reference_datetime = paste0(reference_datetime, "00:00:00"),
                          parameter = parameter,
                          prediction = prediction,
                          site_id = "fcre",
                          depth = 1.5,
                          model_id = "climatology",
                          family = "ensemble",
                          variable_type = "state",
                          variable = focal_variables[j])

    forecast_df <- bind_rows(forecast_df, forecast_variable_df)


  }

  arrow::write_dataset(forecast_df, path = "forecasts/parquet", partitioning = c("site_id","model_id","reference_datetime"))

  FLAREr::generate_forecast_score_arrow(targets_file = target_file,
                                        forecast_df = forecast_df,
                                        use_s3 = FALSE,
                                        local_directory = "scores/parquet",
                                        variable_types = "state")
}




