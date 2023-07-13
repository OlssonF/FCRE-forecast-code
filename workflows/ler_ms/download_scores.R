lake_directory <- here::here()

download.file(url = "https://sandbox.zenodo.org/record/1221469/files/targets.zip?download=1",
              destfile = file.path(lake_directory,"scores.zip"), method = "curl")
unzip(file.path(lake_directory,"scores.zip"))

download.file(url = "https://sandbox.zenodo.org/record/1221469/files/targets.zip?download=1",
              destfile = file.path(lake_directory,"targets.zip"),
              method = "curl")
unzip(file.path(lake_directory,"targets.zip"))

