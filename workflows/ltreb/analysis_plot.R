library(tidyverse)

s <- arrow::schema(
    target_id = arrow::string(),
    model_id = arrow::string(),
    pub_time = arrow::string(),
    site_id = arrow::string(),
    time = arrow::timestamp("s",timezone = "UTC"),
    variable= arrow::string(),
    mean= arrow::float64(),
    sd= arrow::float64(),
    observed= arrow::float64(),
    crps= arrow::float64(),
    logs= arrow::float64(),
    quantile02.5= arrow::float64(),
    quantile10= arrow::float64(),
    quantile90= arrow::float64(),
    quantile97.5= arrow::float64(),
    start_time = arrow::timestamp("s",timezone = "UTC"),
    horizon= arrow::int64())

df <- arrow::open_dataset("/Users/quinn/workfiles/Research/SSC_forecasting/ccc_aed/FCRE-forecast-code/scores/fcre/ms_glmead_oxy",
                          format = "csv", schema = s, skip = 1)

d <- df |> collect()

df2 <- arrow::open_dataset(file.path(lake_directory,"forecasts/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb",
         depth == 1.5) |>
  collect()

df3 <- arrow::open_dataset(file.path(lake_directory,"scores/parquet/site_id=fcre")) |>
  filter(model_id == "ltreb",
         depth == 1.5) |>
  collect() |>
    filter(reference_datetime > "2023-01-01",
  variable == "temperature",
  datetime < "2023-03-26")


y_label <- expression(paste('Water temperature (',degree,'C)', sep = ""))

p_df <- df2 |>
  filter(reference_datetime > "2023-01-01",
         parameter < 8,
         variable == "temperature")
p1 <-  ggplot()+
  geom_line(data = p_df, aes(x = datetime, y = prediction, group = parameter), color = "#529EFF") +
  geom_vline(xintercept = as_datetime("2023-03-26")) +
  geom_point(data = df3, aes(x = datetime,  y = observation), color = "black", size = 0.2, shape = 3) +
  labs(y = y_label, x = "Time") +
  scale_x_datetime(breaks = as_datetime(c("2023-04-01", "2023-07-01", "2023-10-01", "2024-01-01", "2024-04-01")), labels = c("Apr\n2023", "Jul\n2023","Oct\n2023","Jan\n2024","Apr\n2024")) +
  annotate("text", x = lubridate::as_datetime("2023-02-28 23:00:00"), y = 35, label = "Past", size = 2.5) +
  annotate("text", x = lubridate::as_datetime("2023-04-25 23:00:00"), y = 35, label = "Future", size = 2.5) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        #axis.text.x = element_text(size=7.8),
        axis.text = element_text(colour = "black"))

#p1 <- d |>
#  mutate(observed = ifelse(horizon > 0, NA, observed)) |>
#  mutate(depth = as.numeric(stringr::str_split_fixed(site_id, pattern = "-", n = 2)[,2])) |>
#  filter(variable %in% c("temperature"), depth == 1.5, start_time == lubridate::as_datetime("2018-09-15 00:00:00")) |>
#  ggplot(aes(x = time)) +
#  geom_ribbon(aes(ymin = quantile10, ymax = quantile90), fill = "lightblue", color = "lightblue", alpha = 0.3) +
#  geom_line(aes(y = mean), color = "blue") +
#  geom_point(aes(y = observed)) +
#  geom_vline(aes(xintercept = lubridate::as_datetime("2018-09-15 00:00:00"))) +
#  labs(y = y_label, x = "Time", title = "(a)") +
#  annotate("text", x = lubridate::as_datetime("2018-09-11 23:00:00"), y = 26, label = "Past") +
#  annotate("text", x = lubridate::as_datetime("2018-09-17 23:00:00"), y = 26, label = "Future") +
  #annotate("text", x = lubridate::as_datetime("2018-09-08 00:00:00"), y = 26, label = "(a)") +
#  theme_bw() +
#  theme(panel.grid.major = element_blank(),
#        panel.grid.minor = element_blank())

p2 <- d |> filter(horizon >= 0) |>
  mutate(depth = as.numeric(stringr::str_split_fixed(site_id, pattern = "-", n = 2)[,2])) |>
  #filter(depth == 1.5) |>
  filter(start_time < lubridate::as_date("2019-08-26")) |>
  filter(variable %in% c("temperature", "oxygen", "chla")) |>
  mutate(variable = ifelse(variable == "temperature", "Temperature", variable),
         variable = ifelse(variable == "oxygen", "Oxygen", variable),
         variable = ifelse(variable == "chla","Algae",variable)) |>
  filter(!is.na(observed)) |>
  rename(Variable = variable) |>
  group_by(horizon, Variable) |>
  summarize(R2 = cor(mean, observed)^2) |>
  mutate(R2 = ifelse(horizon == 0, 1, R2)) |>
  ggplot(aes(x = horizon, y = R2, color = Variable)) +
  geom_line() +
  scale_color_discrete(name="") +
  labs(x = "Horizon (days in future)", y = expression(R^2)) +
  #annotate("text", x = 0.1, y = 0.85, label = "(b)") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = c(0.75, 0.40),
        legend.margin=margin(0,0,0,0),
        legend.key.height = unit(0.01, "cm"),
        legend.spacing.y = unit(0.001, "cm"),
        legend.text=element_text(size=9),
        axis.text = element_text(colour = "black"))
  #guides(color=guide_legend(title.position = "top"))

library(patchwork)

p3 <- p1 / p2
ggsave(filename = "~/Downloads/test.jpg", plot = p3, device = "jpg", width = 3.2, height = 4)


d |> filter(horizon >= 0) |>
  mutate(depth = as.numeric(stringr::str_split_fixed(site_id, pattern = "-", n = 2)[,2])) |>
  #filter(depth == 1.5) |>
  filter(start_time < lubridate::as_date("2019-08-26")) |>
  filter(variable %in% c("temperature", "oxygen", "chla")) |>
  mutate(variable = ifelse(variable == "temperature", "Temperature", variable),
         variable = ifelse(variable == "oxygen", "Oxygen", variable),
         variable = ifelse(variable == "chla","Chlorophyll a",variable)) |>
  filter(!is.na(observed)) |>
  rename(Variable = variable) |>
  group_by(horizon, Variable) |>
  summarize(R2 = cor(mean, observed)^2) |>
  mutate(R2 = ifelse(horizon == 0, 1, R2)) |>
  pivot_wider(names_from = Variable, values_from = R2)



d |>
  filter(variable %in% c("temperature", "oxygen", "chla", "fdom")) |>
  mutate(depth = as.numeric(stringr::str_split_fixed(site_id, pattern = "-", n = 2)[,2])) |>
  filter(horizon <= 0,
         depth == 1.5) |>
  ggplot(aes(x = time, y = mean, color = factor(start_time))) +
  geom_line() +
  ggplot2::geom_ribbon(ggplot2::aes(ymin = quantile10, ymax = quantile90, color = factor(start_time), fill = factor(start_time)),
                       alpha = 0.70) +
  geom_point(aes(y = observed), color = "black") +
  facet_wrap(~variable, scale = "free")
