lake_directory <- here::here()

download.file(url = "https://zenodo.org/record/8136961/files/scores.zip?download=1",
              destfile = file.path(lake_directory,"scores.zip"), method = "curl")
unzip(file.path(lake_directory,"scores.zip"))

download.file(url = "https://zenodo.org/record/8136961/files/drivers.zip?download=1",
              destfile = file.path(lake_directory,"targets.zip"), method = "curl")
unzip(file.path(lake_directory,"targets.zip"))


# to plot Figure S1 the forecast archive also needs to be downloaded - this can be slow due to the file size
forecasts <- FALSE

if (forecasts == TRUE) {
  download.file(url = "https://zenodo.org/record/8136961/files/forecasts.zip?download=1",
                destfile = file.path(lake_directory,"forecasts.zip"), method = "curl")
  unzip(file.path(lake_directory,"forecasts.zip"))
}

