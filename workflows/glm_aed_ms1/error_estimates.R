library(tidyverse)
d <- read_csv("targets/fcre/fcre-targets-insitu.csv")

d %>%
  filter(depth == 1.5) %>%
  summarize(median = median(observation), .by = "variable") %>%
  pivot_wider(names_from = variable, values_from = median) %>%
  mutate(green = chla / 0.24, #Chla to C ratio
         doc = fdom*0.1, #assume 10% of total DOC is doc
         docr = fdom*0.9) %>%
  pivot_longer(chla:docr, names_to = "variable", values_to = "median") %>%
  mutate(process_error = median * 0.05, #process error is 5% of median
         obs_error = median * 0.05) #observation error is 2.5% of median

#temperature is 0.2 since

d %>%
  filter(depth %in% c(0, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0),
         month(datetime) %in% c(5, 6,7),
         year(datetime) == 2023) %>%
ggplot(aes(x = datetime, y = observation, color = factor(depth))) +
  geom_line() +
  facet_wrap(~variable, scale = "free")


#amm = 1 * 0.025
#nit = 0.1 * 0.025
#Phr = 0.1 * 0.025
