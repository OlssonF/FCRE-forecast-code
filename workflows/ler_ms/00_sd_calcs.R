# Script for estimatsing the  observational uncertainty
# to be used in shadowing time
library(tidyverse)
library(lubridate)

lake_directory <- here::here()

# these are the daily targets
targets <- readr::read_csv('https://s3.flare-forecast.org/targets/ler_ms/fcre/fcre-targets-insitu.csv') |>
  filter(datetime <= lubridate::as_datetime('2020-11-01 00:00:00'),
         variable == 'temperature')

targets |>
  group_by(depth) |>
  summarise(mean = mean(observation),
            sd = sd(observation)) |>
  mutate(cv = (sd/mean)*100)

#======================================#

# Higher frequency data from EDI
FLAREr::get_edi_file(edi_https = "https://pasta.lternet.edu/package/data/eml/edi/271/7/71e6b946b751aa1b966ab5653b01077f",
                     file = 'FCR_Catwalk_2018_2021.csv',
                     lake_directory)

catwalk <- read_csv('./data_raw/FCR_Catwalk_2018_2021.csv') |>
  select(contains(c('datetime','ThermistorTemp'))) |>
  select(-contains('Flag')) |>
  filter(DateTime <= as_datetime('2021-10-01'))

catwalk |>
  pivot_longer(-DateTime, names_to = 'depth', values_to = 'temperature') |>
  ggplot(aes(x=DateTime, y= temperature, colour = depth))+
  geom_line()

mean_interday_sd <- catwalk |>
  pivot_longer(-DateTime,
               names_to = 'depth',
               values_to = 'temperature',
               names_prefix = 'ThermistorTemp_C_') |>
  # get the date only
  mutate(date = as_date(format(DateTime, '%Y-%m-%d')),
         depth = as.numeric(ifelse(depth == 'surface', 0, depth))) |>
  group_by(depth, date) |>

  # calculate the within each day/depth sd
  summarise(sd = sd(temperature, na.rm = T)) |>

  # get the mean sd for each depth
  group_by(depth) |>
  summarise(mean_sd = mean(sd, na.rm = T))

# Calculate the mean sd across the water column
wc_mean_sd <- mean(mean_interday_sd$mean_sd)

mean_interday_sd |>
  ggplot(aes(x=mean_sd,  y=depth)) +
  geom_point() +
  geom_text(aes(label = round(mean_sd, 2)), size = 4, hjust = -0.1, vjust = -0.1) +
  geom_vline(xintercept = wc_mean_sd, ) +
  scale_y_reverse() +
  theme_bw() +
  labs(x= 'Mean daily standard deviation')
