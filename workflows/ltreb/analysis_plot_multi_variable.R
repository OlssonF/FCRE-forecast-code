
df2 <- arrow::open_dataset(file.path(lake_directory,"forecasts/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb",
         depth == 1.5) |>
  collect()

df3 <- arrow::open_dataset(file.path(lake_directory,"scores/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb",
         depth == 1.5) |>
  collect() #|>
         #datetime < "2023-03-26")


df_da <- arrow::open_dataset(file.path(lake_directory,"scores/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb_2_week_da",
         depth == 1.5) |>
  collect()

df_da_summer <- df_da %>%
  filter(datetime >= as.POSIXct('2021-04-01'),
         datetime <= as.POSIXct('2021-08-31'))

df_forecast <- df2 |>
  filter(reference_datetime > "2023-01-01",
         parameter < 8,
         variable %in% c("temperature","chla",'oxygen','fdom'))
         #variable %in% c("temperature","chla"), depth == 1.5)


p_forecast <- df_forecast |>
  ggplot(aes(x=datetime, y=prediction, group= parameter)) +
  geom_line(aes(color = variable)) +
  geom_vline(xintercept = as_datetime("2023-03-26")) +
  facet_wrap(~variable, scales = 'free')

p_forecast


##scores
df_scores <- df_da |>
  filter(reference_datetime == "2021-12-31 00:00:00",
         variable %in% c("temperature","chla",'oxygen','fdom','NIT_nit','NIT_amm'))
         #variable %in% c("PHY_cyano","PHY_diatom","PHY_green"))

df_summer_scores <- df_da_summer |>
  filter(reference_datetime == "2021-12-31 00:00:00",
         #variable %in% c("temperature","chla",'oxygen','fdom','NIT_nit','NIT_amm'))
         variable %in% c("PHY_cyano","PHY_diatom","PHY_green"))


daily <- seq.Date(starting_date,second_date, by = 1)
fortnightly <- daily[seq(1,length(daily),by=14)]


p_scores <- df_summer_scores |>
  ggplot(aes(x=datetime, y=median)) +
  geom_ribbon(aes(ymin=quantile02.5, ymax = quantile97.5), fill = 'grey70') +
  geom_point(aes(x = datetime,  y = observation), color = "darkred", size = 0.8, shape = 3) +
  geom_line(aes(x=datetime,y=median)) +
  #geom_vline(xintercept = as_datetime("2023-03-26")) +
  geom_vline(xintercept = as_datetime(fortnightly), color = 'darkred') +
  facet_wrap(~variable, scales = 'free')

p_scores

#geom_ribbon 97.5 aned 2.5
#put on median of geom)line ontop of that
#geom_point for observations



### combine full uncertainty and temp uncertainty and plot together
df_no_unc <- arrow::open_dataset(file.path(lake_directory,"scores/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb_no_uncertainty",
         depth == 1.5) |>
  collect()

df_temp_unc <- arrow::open_dataset(file.path(lake_directory,"scores/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb_temp_uncertainty",
         depth == 1.5) |>
  collect() %>%
  mutate(model_id = 'ltreb_temp_uncertainty')## add rename of model_id column

df_full_unc <- arrow::open_dataset(file.path(lake_directory,"scores/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb",
         depth == 1.5) |>
  collect()

df_combined <- rbind(df_temp_unc,df_full_unc,df_no_unc) %>%
  filter(reference_datetime == "2021-12-31 00:00:00",
         variable %in% c("temperature","chla",'oxygen','fdom'))

p_scores_combined <- df_combined |>
  ggplot(aes(x=datetime, y=median, group = model_id, color = model_id)) +
  geom_line() +
  #geom_ribbon(aes(ymin=quantile02.5, ymax = quantile97.5), fill = 'grey70') +
  geom_point(aes(x = datetime,  y = observation), color = "darkred", size = 0.8, shape = 3) +
  #geom_line(aes(x=datetime,y=median)) +
  geom_line(aes(x = datetime,y = quantile02.5)) +
  geom_line(aes(x = datetime,y = quantile97.5)) +
  geom_vline(xintercept = as_datetime("2023-03-26")) +
  facet_wrap(~variable, scales = 'free') +
  scale_color_manual(values = c("darkblue",
                                'black',
                                "darkgreen"))

p_scores_combined
