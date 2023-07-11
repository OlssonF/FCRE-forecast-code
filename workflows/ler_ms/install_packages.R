# install packages
install.packages(c("remotes", "tidyverse", "lubridate", "arrow", "fable", "tsibble"))
install.packages(c("here", "aws.s3"))
install.packages('ggpubr', 'ggh4x')
remotes::install_cran("xtable")

remotes::install_github("GLEON/rLakeAnalyzer", ref = "e74974f74082111065bd9cd759527f16608b3c82")

remotes::install_github("FLARE-forecast/GLM3r", ref = "a57f41d9e8e9a12e72675f2e02f032fe9f27b11c")
remotes::install_github("FLARE-forecast/GOTMr", ref = "c7c7ed3d8259325a86be5ba2ea9c7e403d17c7ab")
remotes::install_github("FLARE-forecast/SimstratR", ref = "c6ccb997705f700f6ff6cf4c3d5c139a69c638bf")
remotes::install_github("aemon-j/gotmtools", ref = "yaml")
remotes::install_github("rqthomas/glmtools", ref = "b50e9a7b73e41afcd8119e2b9ac172c1c7beb51f")
remotes::install_github("FLARE-forecast/LakeEnsemblR", ref = "b2927e22767a59ae46d709c91e3e8b87d5a6bf84")

remotes::install_github("FLARE-forecast/FLAREr", ref = "69673299b23bc0ad68d0b627045a7059554f04fe")
remotes::install_github("FLARE-forecast/FLARErLER", ref = "5367bd0533a85c71c0af9c514b0808eed4d470cc")

