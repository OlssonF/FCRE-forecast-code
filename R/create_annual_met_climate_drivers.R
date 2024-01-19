# library(tidyverse)
# library(lubridate)
# library(arrow)
#
# ## use existing stage2 data as template
# s3 <- arrow::s3_bucket("drivers/noaa/gefs-v12/stage2/parquet/0", endpoint_override = "s3.flare-forecast.org", anonymous = TRUE)
# df_stage2 <- arrow::open_dataset(s3) %>% filter(site_id == "fcre", reference_datetime == lubridate::as_datetime('2021-03-01 00:00:00')) %>% collect()
#
#
# ## PULL EXISTING OBS MET DATA FROM EDI
#
# # Package ID: edi.389.7 Cataloging System:https://pasta.edirepository.org.
# # Data set title: Time series of high-frequency meteorological data at Falling Creek Reservoir, Virginia, USA 2015-2022.
# # Data set creator:  Cayelan Carey - Virginia Tech
# # Data set creator:  Adrienne Breef-Pilz - Virginia Tech
# # Contact:  Cayelan Carey -  Virginia Tech  - Cayelan@vt.edu
# # Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu
#
# inUrl1  <- "https://pasta.lternet.edu/package/data/eml/edi/389/7/02d36541de9088f2dd99d79dc3a7a853"
# infile1 <- tempfile()
# try(download.file(inUrl1,infile1,method="curl"))
# if (is.na(file.size(infile1))) download.file(inUrl1,infile1,method="auto")
#
#
# dt1 <-read.csv(infile1,header=F
#                ,skip=1
#                ,sep=","
#                , col.names=c(
#                  "Reservoir",
#                  "Site",
#                  "DateTime",
#                  "Record",
#                  "CR3000Battery_V",
#                  "CR3000Panel_Temp_C",
#                  "PAR_umolm2s_Average",
#                  "PAR_Total_mmol_m2",
#                  "BP_Average_kPa",
#                  "AirTemp_C_Average",
#                  "RH_percent",
#                  "Rain_Total_mm",
#                  "WindSpeed_Average_m_s",
#                  "WindDir_degrees",
#                  "ShortwaveRadiationUp_Average_W_m2",
#                  "ShortwaveRadiationDown_Average_W_m2",
#                  "InfraredRadiationUp_Average_W_m2",
#                  "InfraredRadiationDown_Average_W_m2",
#                  "Albedo_Average_W_m2",
#                  "Flag_PAR_umolm2s_Average",
#                  "Note_PAR_umolm2s_Average",
#                  "Flag_PAR_Total_mmol_m2",
#                  "Note_PAR_Total_mmol_m2",
#                  "Flag_BP_Average_kPa",
#                  "Note_BP_Average_kPa",
#                  "Flag_AirTemp_C_Average",
#                  "Note_AirTemp_C_Average",
#                  "Flag_RH_percent",
#                  "Note_RH_percent",
#                  "Flag_Rain_Total_mm",
#                  "Note_Rain_Total_mm",
#                  "Flag_WindSpeed_Average_m_s",
#                  "Note_WindSpeed_Average_m_s",
#                  "Flag_WindDir_degrees",
#                  "Note_WindDir_degrees",
#                  "Flag_ShortwaveRadiationUp_Average_W_m2",
#                  "Note_ShortwaveRadiationUp_Average_W_m2",
#                  "Flag_ShortwaveRadiationDown_Average_W_m2",
#                  "Note_ShortwaveRadiationDown_Average_W_m2",
#                  "Flag_InfraredRadiationUp_Average_W_m2",
#                  "Note_InfraredRadiationUp_Average_W_m2",
#                  "Flag_InfraredRadiationDown_Average_W_m2",
#                  "Note_InfraredRadiationDown_Average_W_m2",
#                  "Flag_Albedo_Average_W_m2",
#                  "Note_Albedo_Average_W_m2"    ), check.names=TRUE)
#
# unlink(infile1)
#
# # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings
#
# if (class(dt1$Reservoir)!="factor") dt1$Reservoir<- as.factor(dt1$Reservoir)
# if (class(dt1$Site)=="factor") dt1$Site <-as.numeric(levels(dt1$Site))[as.integer(dt1$Site) ]
# if (class(dt1$Site)=="character") dt1$Site <-as.numeric(dt1$Site)
# # attempting to convert dt1$DateTime dateTime string to R date structure (date or POSIXct)
# tmpDateFormat<-"%Y-%m-%d %H:%M:%S"
# tmp1DateTime<-as.POSIXct(dt1$DateTime,format=tmpDateFormat)
# # Keep the new dates only if they all converted correctly
# if(length(tmp1DateTime) == length(tmp1DateTime[!is.na(tmp1DateTime)])){dt1$DateTime <- tmp1DateTime } else {print("Date conversion failed for dt1$DateTime. Please inspect the data and do the date conversion yourself.")}
# rm(tmpDateFormat,tmp1DateTime)
# if (class(dt1$Record)=="factor") dt1$Record <-as.numeric(levels(dt1$Record))[as.integer(dt1$Record) ]
# if (class(dt1$Record)=="character") dt1$Record <-as.numeric(dt1$Record)
# if (class(dt1$CR3000Battery_V)=="factor") dt1$CR3000Battery_V <-as.numeric(levels(dt1$CR3000Battery_V))[as.integer(dt1$CR3000Battery_V) ]
# if (class(dt1$CR3000Battery_V)=="character") dt1$CR3000Battery_V <-as.numeric(dt1$CR3000Battery_V)
# if (class(dt1$CR3000Panel_Temp_C)=="factor") dt1$CR3000Panel_Temp_C <-as.numeric(levels(dt1$CR3000Panel_Temp_C))[as.integer(dt1$CR3000Panel_Temp_C) ]
# if (class(dt1$CR3000Panel_Temp_C)=="character") dt1$CR3000Panel_Temp_C <-as.numeric(dt1$CR3000Panel_Temp_C)
# if (class(dt1$PAR_umolm2s_Average)=="factor") dt1$PAR_umolm2s_Average <-as.numeric(levels(dt1$PAR_umolm2s_Average))[as.integer(dt1$PAR_umolm2s_Average) ]
# if (class(dt1$PAR_umolm2s_Average)=="character") dt1$PAR_umolm2s_Average <-as.numeric(dt1$PAR_umolm2s_Average)
# if (class(dt1$PAR_Total_mmol_m2)=="factor") dt1$PAR_Total_mmol_m2 <-as.numeric(levels(dt1$PAR_Total_mmol_m2))[as.integer(dt1$PAR_Total_mmol_m2) ]
# if (class(dt1$PAR_Total_mmol_m2)=="character") dt1$PAR_Total_mmol_m2 <-as.numeric(dt1$PAR_Total_mmol_m2)
# if (class(dt1$BP_Average_kPa)=="factor") dt1$BP_Average_kPa <-as.numeric(levels(dt1$BP_Average_kPa))[as.integer(dt1$BP_Average_kPa) ]
# if (class(dt1$BP_Average_kPa)=="character") dt1$BP_Average_kPa <-as.numeric(dt1$BP_Average_kPa)
# if (class(dt1$AirTemp_C_Average)=="factor") dt1$AirTemp_C_Average <-as.numeric(levels(dt1$AirTemp_C_Average))[as.integer(dt1$AirTemp_C_Average) ]
# if (class(dt1$AirTemp_C_Average)=="character") dt1$AirTemp_C_Average <-as.numeric(dt1$AirTemp_C_Average)
# if (class(dt1$RH_percent)=="factor") dt1$RH_percent <-as.numeric(levels(dt1$RH_percent))[as.integer(dt1$RH_percent) ]
# if (class(dt1$RH_percent)=="character") dt1$RH_percent <-as.numeric(dt1$RH_percent)
# if (class(dt1$Rain_Total_mm)=="factor") dt1$Rain_Total_mm <-as.numeric(levels(dt1$Rain_Total_mm))[as.integer(dt1$Rain_Total_mm) ]
# if (class(dt1$Rain_Total_mm)=="character") dt1$Rain_Total_mm <-as.numeric(dt1$Rain_Total_mm)
# if (class(dt1$WindSpeed_Average_m_s)=="factor") dt1$WindSpeed_Average_m_s <-as.numeric(levels(dt1$WindSpeed_Average_m_s))[as.integer(dt1$WindSpeed_Average_m_s) ]
# if (class(dt1$WindSpeed_Average_m_s)=="character") dt1$WindSpeed_Average_m_s <-as.numeric(dt1$WindSpeed_Average_m_s)
# if (class(dt1$WindDir_degrees)=="factor") dt1$WindDir_degrees <-as.numeric(levels(dt1$WindDir_degrees))[as.integer(dt1$WindDir_degrees) ]
# if (class(dt1$WindDir_degrees)=="character") dt1$WindDir_degrees <-as.numeric(dt1$WindDir_degrees)
# if (class(dt1$ShortwaveRadiationUp_Average_W_m2)=="factor") dt1$ShortwaveRadiationUp_Average_W_m2 <-as.numeric(levels(dt1$ShortwaveRadiationUp_Average_W_m2))[as.integer(dt1$ShortwaveRadiationUp_Average_W_m2) ]
# if (class(dt1$ShortwaveRadiationUp_Average_W_m2)=="character") dt1$ShortwaveRadiationUp_Average_W_m2 <-as.numeric(dt1$ShortwaveRadiationUp_Average_W_m2)
# if (class(dt1$ShortwaveRadiationDown_Average_W_m2)=="factor") dt1$ShortwaveRadiationDown_Average_W_m2 <-as.numeric(levels(dt1$ShortwaveRadiationDown_Average_W_m2))[as.integer(dt1$ShortwaveRadiationDown_Average_W_m2) ]
# if (class(dt1$ShortwaveRadiationDown_Average_W_m2)=="character") dt1$ShortwaveRadiationDown_Average_W_m2 <-as.numeric(dt1$ShortwaveRadiationDown_Average_W_m2)
# if (class(dt1$InfraredRadiationUp_Average_W_m2)=="factor") dt1$InfraredRadiationUp_Average_W_m2 <-as.numeric(levels(dt1$InfraredRadiationUp_Average_W_m2))[as.integer(dt1$InfraredRadiationUp_Average_W_m2) ]
# if (class(dt1$InfraredRadiationUp_Average_W_m2)=="character") dt1$InfraredRadiationUp_Average_W_m2 <-as.numeric(dt1$InfraredRadiationUp_Average_W_m2)
# if (class(dt1$InfraredRadiationDown_Average_W_m2)=="factor") dt1$InfraredRadiationDown_Average_W_m2 <-as.numeric(levels(dt1$InfraredRadiationDown_Average_W_m2))[as.integer(dt1$InfraredRadiationDown_Average_W_m2) ]
# if (class(dt1$InfraredRadiationDown_Average_W_m2)=="character") dt1$InfraredRadiationDown_Average_W_m2 <-as.numeric(dt1$InfraredRadiationDown_Average_W_m2)
# if (class(dt1$Albedo_Average_W_m2)=="factor") dt1$Albedo_Average_W_m2 <-as.numeric(levels(dt1$Albedo_Average_W_m2))[as.integer(dt1$Albedo_Average_W_m2) ]
# if (class(dt1$Albedo_Average_W_m2)=="character") dt1$Albedo_Average_W_m2 <-as.numeric(dt1$Albedo_Average_W_m2)
# if (class(dt1$Flag_PAR_umolm2s_Average)!="factor") dt1$Flag_PAR_umolm2s_Average<- as.factor(dt1$Flag_PAR_umolm2s_Average)
# if (class(dt1$Note_PAR_umolm2s_Average)!="factor") dt1$Note_PAR_umolm2s_Average<- as.factor(dt1$Note_PAR_umolm2s_Average)
# if (class(dt1$Flag_PAR_Total_mmol_m2)!="factor") dt1$Flag_PAR_Total_mmol_m2<- as.factor(dt1$Flag_PAR_Total_mmol_m2)
# if (class(dt1$Note_PAR_Total_mmol_m2)!="factor") dt1$Note_PAR_Total_mmol_m2<- as.factor(dt1$Note_PAR_Total_mmol_m2)
# if (class(dt1$Flag_BP_Average_kPa)!="factor") dt1$Flag_BP_Average_kPa<- as.factor(dt1$Flag_BP_Average_kPa)
# if (class(dt1$Note_BP_Average_kPa)!="factor") dt1$Note_BP_Average_kPa<- as.factor(dt1$Note_BP_Average_kPa)
# if (class(dt1$Flag_AirTemp_C_Average)!="factor") dt1$Flag_AirTemp_C_Average<- as.factor(dt1$Flag_AirTemp_C_Average)
# if (class(dt1$Note_AirTemp_C_Average)!="factor") dt1$Note_AirTemp_C_Average<- as.factor(dt1$Note_AirTemp_C_Average)
# if (class(dt1$Flag_RH_percent)!="factor") dt1$Flag_RH_percent<- as.factor(dt1$Flag_RH_percent)
# if (class(dt1$Note_RH_percent)!="factor") dt1$Note_RH_percent<- as.factor(dt1$Note_RH_percent)
# if (class(dt1$Flag_Rain_Total_mm)!="factor") dt1$Flag_Rain_Total_mm<- as.factor(dt1$Flag_Rain_Total_mm)
# if (class(dt1$Note_Rain_Total_mm)!="factor") dt1$Note_Rain_Total_mm<- as.factor(dt1$Note_Rain_Total_mm)
# if (class(dt1$Flag_WindSpeed_Average_m_s)!="factor") dt1$Flag_WindSpeed_Average_m_s<- as.factor(dt1$Flag_WindSpeed_Average_m_s)
# if (class(dt1$Note_WindSpeed_Average_m_s)!="factor") dt1$Note_WindSpeed_Average_m_s<- as.factor(dt1$Note_WindSpeed_Average_m_s)
# if (class(dt1$Flag_WindDir_degrees)!="factor") dt1$Flag_WindDir_degrees<- as.factor(dt1$Flag_WindDir_degrees)
# if (class(dt1$Note_WindDir_degrees)!="factor") dt1$Note_WindDir_degrees<- as.factor(dt1$Note_WindDir_degrees)
# if (class(dt1$Flag_ShortwaveRadiationUp_Average_W_m2)!="factor") dt1$Flag_ShortwaveRadiationUp_Average_W_m2<- as.factor(dt1$Flag_ShortwaveRadiationUp_Average_W_m2)
# if (class(dt1$Note_ShortwaveRadiationUp_Average_W_m2)!="factor") dt1$Note_ShortwaveRadiationUp_Average_W_m2<- as.factor(dt1$Note_ShortwaveRadiationUp_Average_W_m2)
# if (class(dt1$Flag_ShortwaveRadiationDown_Average_W_m2)!="factor") dt1$Flag_ShortwaveRadiationDown_Average_W_m2<- as.factor(dt1$Flag_ShortwaveRadiationDown_Average_W_m2)
# if (class(dt1$Note_ShortwaveRadiationDown_Average_W_m2)!="factor") dt1$Note_ShortwaveRadiationDown_Average_W_m2<- as.factor(dt1$Note_ShortwaveRadiationDown_Average_W_m2)
# if (class(dt1$Flag_InfraredRadiationUp_Average_W_m2)!="factor") dt1$Flag_InfraredRadiationUp_Average_W_m2<- as.factor(dt1$Flag_InfraredRadiationUp_Average_W_m2)
# if (class(dt1$Note_InfraredRadiationUp_Average_W_m2)!="factor") dt1$Note_InfraredRadiationUp_Average_W_m2<- as.factor(dt1$Note_InfraredRadiationUp_Average_W_m2)
# if (class(dt1$Flag_InfraredRadiationDown_Average_W_m2)!="factor") dt1$Flag_InfraredRadiationDown_Average_W_m2<- as.factor(dt1$Flag_InfraredRadiationDown_Average_W_m2)
# if (class(dt1$Note_InfraredRadiationDown_Average_W_m2)!="factor") dt1$Note_InfraredRadiationDown_Average_W_m2<- as.factor(dt1$Note_InfraredRadiationDown_Average_W_m2)
# if (class(dt1$Flag_Albedo_Average_W_m2)!="factor") dt1$Flag_Albedo_Average_W_m2<- as.factor(dt1$Flag_Albedo_Average_W_m2)
# if (class(dt1$Note_Albedo_Average_W_m2)!="factor") dt1$Note_Albedo_Average_W_m2<- as.factor(dt1$Note_Albedo_Average_W_m2)
#
# # Convert Missing Values to NA for non-dates
#
# dt1$Reservoir <- as.factor(ifelse((trimws(as.character(dt1$Reservoir))==trimws("NA")),NA,as.character(dt1$Reservoir)))
# dt1$Site <- ifelse((trimws(as.character(dt1$Site))==trimws("NA")),NA,dt1$Site)
# suppressWarnings(dt1$Site <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$Site))==as.character(as.numeric("NA"))),NA,dt1$Site))
# dt1$Record <- ifelse((trimws(as.character(dt1$Record))==trimws("NA")),NA,dt1$Record)
# suppressWarnings(dt1$Record <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$Record))==as.character(as.numeric("NA"))),NA,dt1$Record))
# dt1$CR3000Battery_V <- ifelse((trimws(as.character(dt1$CR3000Battery_V))==trimws("NA")),NA,dt1$CR3000Battery_V)
# suppressWarnings(dt1$CR3000Battery_V <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$CR3000Battery_V))==as.character(as.numeric("NA"))),NA,dt1$CR3000Battery_V))
# dt1$CR3000Panel_Temp_C <- ifelse((trimws(as.character(dt1$CR3000Panel_Temp_C))==trimws("NA")),NA,dt1$CR3000Panel_Temp_C)
# suppressWarnings(dt1$CR3000Panel_Temp_C <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$CR3000Panel_Temp_C))==as.character(as.numeric("NA"))),NA,dt1$CR3000Panel_Temp_C))
# dt1$PAR_umolm2s_Average <- ifelse((trimws(as.character(dt1$PAR_umolm2s_Average))==trimws("NA")),NA,dt1$PAR_umolm2s_Average)
# suppressWarnings(dt1$PAR_umolm2s_Average <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$PAR_umolm2s_Average))==as.character(as.numeric("NA"))),NA,dt1$PAR_umolm2s_Average))
# dt1$PAR_Total_mmol_m2 <- ifelse((trimws(as.character(dt1$PAR_Total_mmol_m2))==trimws("NA")),NA,dt1$PAR_Total_mmol_m2)
# suppressWarnings(dt1$PAR_Total_mmol_m2 <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$PAR_Total_mmol_m2))==as.character(as.numeric("NA"))),NA,dt1$PAR_Total_mmol_m2))
# dt1$BP_Average_kPa <- ifelse((trimws(as.character(dt1$BP_Average_kPa))==trimws("NA")),NA,dt1$BP_Average_kPa)
# suppressWarnings(dt1$BP_Average_kPa <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$BP_Average_kPa))==as.character(as.numeric("NA"))),NA,dt1$BP_Average_kPa))
# dt1$AirTemp_C_Average <- ifelse((trimws(as.character(dt1$AirTemp_C_Average))==trimws("NA")),NA,dt1$AirTemp_C_Average)
# suppressWarnings(dt1$AirTemp_C_Average <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$AirTemp_C_Average))==as.character(as.numeric("NA"))),NA,dt1$AirTemp_C_Average))
# dt1$RH_percent <- ifelse((trimws(as.character(dt1$RH_percent))==trimws("NA")),NA,dt1$RH_percent)
# suppressWarnings(dt1$RH_percent <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$RH_percent))==as.character(as.numeric("NA"))),NA,dt1$RH_percent))
# dt1$Rain_Total_mm <- ifelse((trimws(as.character(dt1$Rain_Total_mm))==trimws("NA")),NA,dt1$Rain_Total_mm)
# suppressWarnings(dt1$Rain_Total_mm <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$Rain_Total_mm))==as.character(as.numeric("NA"))),NA,dt1$Rain_Total_mm))
# dt1$WindSpeed_Average_m_s <- ifelse((trimws(as.character(dt1$WindSpeed_Average_m_s))==trimws("NA")),NA,dt1$WindSpeed_Average_m_s)
# suppressWarnings(dt1$WindSpeed_Average_m_s <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$WindSpeed_Average_m_s))==as.character(as.numeric("NA"))),NA,dt1$WindSpeed_Average_m_s))
# dt1$WindDir_degrees <- ifelse((trimws(as.character(dt1$WindDir_degrees))==trimws("NA")),NA,dt1$WindDir_degrees)
# suppressWarnings(dt1$WindDir_degrees <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$WindDir_degrees))==as.character(as.numeric("NA"))),NA,dt1$WindDir_degrees))
# dt1$ShortwaveRadiationUp_Average_W_m2 <- ifelse((trimws(as.character(dt1$ShortwaveRadiationUp_Average_W_m2))==trimws("NA")),NA,dt1$ShortwaveRadiationUp_Average_W_m2)
# suppressWarnings(dt1$ShortwaveRadiationUp_Average_W_m2 <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$ShortwaveRadiationUp_Average_W_m2))==as.character(as.numeric("NA"))),NA,dt1$ShortwaveRadiationUp_Average_W_m2))
# dt1$ShortwaveRadiationDown_Average_W_m2 <- ifelse((trimws(as.character(dt1$ShortwaveRadiationDown_Average_W_m2))==trimws("NA")),NA,dt1$ShortwaveRadiationDown_Average_W_m2)
# suppressWarnings(dt1$ShortwaveRadiationDown_Average_W_m2 <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$ShortwaveRadiationDown_Average_W_m2))==as.character(as.numeric("NA"))),NA,dt1$ShortwaveRadiationDown_Average_W_m2))
# dt1$InfraredRadiationUp_Average_W_m2 <- ifelse((trimws(as.character(dt1$InfraredRadiationUp_Average_W_m2))==trimws("NA")),NA,dt1$InfraredRadiationUp_Average_W_m2)
# suppressWarnings(dt1$InfraredRadiationUp_Average_W_m2 <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$InfraredRadiationUp_Average_W_m2))==as.character(as.numeric("NA"))),NA,dt1$InfraredRadiationUp_Average_W_m2))
# dt1$InfraredRadiationDown_Average_W_m2 <- ifelse((trimws(as.character(dt1$InfraredRadiationDown_Average_W_m2))==trimws("NA")),NA,dt1$InfraredRadiationDown_Average_W_m2)
# suppressWarnings(dt1$InfraredRadiationDown_Average_W_m2 <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$InfraredRadiationDown_Average_W_m2))==as.character(as.numeric("NA"))),NA,dt1$InfraredRadiationDown_Average_W_m2))
# dt1$Albedo_Average_W_m2 <- ifelse((trimws(as.character(dt1$Albedo_Average_W_m2))==trimws("NA")),NA,dt1$Albedo_Average_W_m2)
# suppressWarnings(dt1$Albedo_Average_W_m2 <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$Albedo_Average_W_m2))==as.character(as.numeric("NA"))),NA,dt1$Albedo_Average_W_m2))
# dt1$Flag_PAR_umolm2s_Average <- as.factor(ifelse((trimws(as.character(dt1$Flag_PAR_umolm2s_Average))==trimws("NA")),NA,as.character(dt1$Flag_PAR_umolm2s_Average)))
# dt1$Note_PAR_umolm2s_Average <- as.factor(ifelse((trimws(as.character(dt1$Note_PAR_umolm2s_Average))==trimws("NA")),NA,as.character(dt1$Note_PAR_umolm2s_Average)))
# dt1$Flag_PAR_Total_mmol_m2 <- as.factor(ifelse((trimws(as.character(dt1$Flag_PAR_Total_mmol_m2))==trimws("NA")),NA,as.character(dt1$Flag_PAR_Total_mmol_m2)))
# dt1$Note_PAR_Total_mmol_m2 <- as.factor(ifelse((trimws(as.character(dt1$Note_PAR_Total_mmol_m2))==trimws("NA")),NA,as.character(dt1$Note_PAR_Total_mmol_m2)))
# dt1$Flag_BP_Average_kPa <- as.factor(ifelse((trimws(as.character(dt1$Flag_BP_Average_kPa))==trimws("NA")),NA,as.character(dt1$Flag_BP_Average_kPa)))
# dt1$Note_BP_Average_kPa <- as.factor(ifelse((trimws(as.character(dt1$Note_BP_Average_kPa))==trimws("NA")),NA,as.character(dt1$Note_BP_Average_kPa)))
# dt1$Flag_AirTemp_C_Average <- as.factor(ifelse((trimws(as.character(dt1$Flag_AirTemp_C_Average))==trimws("NA")),NA,as.character(dt1$Flag_AirTemp_C_Average)))
# dt1$Note_AirTemp_C_Average <- as.factor(ifelse((trimws(as.character(dt1$Note_AirTemp_C_Average))==trimws("NA")),NA,as.character(dt1$Note_AirTemp_C_Average)))
# dt1$Flag_RH_percent <- as.factor(ifelse((trimws(as.character(dt1$Flag_RH_percent))==trimws("NA")),NA,as.character(dt1$Flag_RH_percent)))
# dt1$Note_RH_percent <- as.factor(ifelse((trimws(as.character(dt1$Note_RH_percent))==trimws("NA")),NA,as.character(dt1$Note_RH_percent)))
# dt1$Flag_Rain_Total_mm <- as.factor(ifelse((trimws(as.character(dt1$Flag_Rain_Total_mm))==trimws("NA")),NA,as.character(dt1$Flag_Rain_Total_mm)))
# dt1$Note_Rain_Total_mm <- as.factor(ifelse((trimws(as.character(dt1$Note_Rain_Total_mm))==trimws("NA")),NA,as.character(dt1$Note_Rain_Total_mm)))
# dt1$Flag_WindSpeed_Average_m_s <- as.factor(ifelse((trimws(as.character(dt1$Flag_WindSpeed_Average_m_s))==trimws("NA")),NA,as.character(dt1$Flag_WindSpeed_Average_m_s)))
# dt1$Note_WindSpeed_Average_m_s <- as.factor(ifelse((trimws(as.character(dt1$Note_WindSpeed_Average_m_s))==trimws("NA")),NA,as.character(dt1$Note_WindSpeed_Average_m_s)))
# dt1$Flag_WindDir_degrees <- as.factor(ifelse((trimws(as.character(dt1$Flag_WindDir_degrees))==trimws("NA")),NA,as.character(dt1$Flag_WindDir_degrees)))
# dt1$Note_WindDir_degrees <- as.factor(ifelse((trimws(as.character(dt1$Note_WindDir_degrees))==trimws("NA")),NA,as.character(dt1$Note_WindDir_degrees)))
# dt1$Flag_ShortwaveRadiationUp_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Flag_ShortwaveRadiationUp_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Flag_ShortwaveRadiationUp_Average_W_m2)))
# dt1$Note_ShortwaveRadiationUp_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Note_ShortwaveRadiationUp_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Note_ShortwaveRadiationUp_Average_W_m2)))
# dt1$Flag_ShortwaveRadiationDown_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Flag_ShortwaveRadiationDown_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Flag_ShortwaveRadiationDown_Average_W_m2)))
# dt1$Note_ShortwaveRadiationDown_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Note_ShortwaveRadiationDown_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Note_ShortwaveRadiationDown_Average_W_m2)))
# dt1$Flag_InfraredRadiationUp_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Flag_InfraredRadiationUp_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Flag_InfraredRadiationUp_Average_W_m2)))
# dt1$Note_InfraredRadiationUp_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Note_InfraredRadiationUp_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Note_InfraredRadiationUp_Average_W_m2)))
# dt1$Flag_InfraredRadiationDown_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Flag_InfraredRadiationDown_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Flag_InfraredRadiationDown_Average_W_m2)))
# dt1$Note_InfraredRadiationDown_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Note_InfraredRadiationDown_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Note_InfraredRadiationDown_Average_W_m2)))
# dt1$Flag_Albedo_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Flag_Albedo_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Flag_Albedo_Average_W_m2)))
# dt1$Note_Albedo_Average_W_m2 <- as.factor(ifelse((trimws(as.character(dt1$Note_Albedo_Average_W_m2))==trimws("NA")),NA,as.character(dt1$Note_Albedo_Average_W_m2)))
#
# ## READ IN RECENT DATA FROM GITHUB
# dt_new <- read.csv("https://raw.githubusercontent.com/FLARE-forecast/FCRE-data/fcre-metstation-data/FCRmet_L1.csv")
#
#
# # COMBINE EDI DATA WITH RECENT DATA
# df_met_full <- rbind(dt1,dt_new)
#
#
# ## CREATE DATE/TIME COLUMNS AND REMOVE COLUMNS WE DONT NEED
# df_date_col_select <- df_met_full %>%
#   mutate(doy = as.numeric(strftime(DateTime, format = "%j"))) %>%
#   mutate(date = format(as.Date(DateTime))) %>%
#   mutate(hour = hour(DateTime)) %>%
#   select(-contains('Note')) %>%
#   select(-contains('Flag')) %>%
#   select(-c('Reservoir','Site','Albedo_Average_W_m2','CR3000Battery_V','CR3000Panel_Temp_C','PAR_umolm2s_Average','PAR_Total_mmol_m2','InfraredRadiationDown_Average_W_m2', 'ShortwaveRadiationDown_Average_W_m2'))
#
# # REMOVE DATA OBJECTS WE DONT NEED TO CLEAR UP RAM SPACE
# rm(df_met_full)
#
# ### RENAME VARIABLES AND CALCULATE HOURLY AVERAGES
# df_hourly_avgs <- df_date_col_select %>%
#   group_by(date,hour) %>%
#   mutate(northward_wind  = mean(WindSpeed_Average_m_s*cos(WindDir_degrees),na.rm=TRUE)) %>% #identify u component of wind
#   mutate(eastward_wind = mean(WindSpeed_Average_m_s*sin(WindDir_degrees),na.rm=TRUE)) %>% #identify v component of wind
#   mutate(air_pressure = mean(BP_Average_kPa*1000,na.rm=TRUE)) %>% #convert kPa to Pa
#   mutate(air_temperature = mean(AirTemp_C_Average+273.15, na.rm =TRUE)) %>%
#   mutate(relative_humidity = mean(RH_percent/100, na.rm=TRUE)) %>%
#   mutate(precipitation_flux = mean(Rain_Total_mm/3600, na.rm=TRUE)) %>% #convert from mm/hr to kg/m2s
#   mutate(surface_downwelling_longwave_flux_in_air = mean(InfraredRadiationUp_Average_W_m2, na.rm=TRUE)) %>%
#   mutate(surface_downwelling_shortwave_flux_in_air = mean(ShortwaveRadiationUp_Average_W_m2,na.rm=TRUE)) %>%
#   mutate(datetime = as.POSIXct(paste0(date,' ',hour,':00'), format = '%Y-%m-%d %H:%M', tz = 'UTC')) %>%
#   ungroup() %>%
#   distinct(date, hour, .keep_all = TRUE) %>%
#   select(datetime,date,hour,doy,northward_wind,eastward_wind,air_pressure,air_temperature,relative_humidity,precipitation_flux,surface_downwelling_longwave_flux_in_air,surface_downwelling_shortwave_flux_in_air)
#
# # create base df of all dates/hours needed for data
# full_year <- data.frame(datetime = seq(as.POSIXct('2015-07-07 15:00:00'),as.POSIXct('2023-03-31 08:00:00'),by = 'hour'))
#
# # join data onto datetime base df to create NA records for missing dates
# df_date_match <- full_year %>% full_join(df_hourly_avgs, by='datetime') %>% select(-doy,-hour,-date)
#
#
# ### CONVERT DATA TO LONG FORMAT AND SUBSET TO INCLUDE ONLY FULL YEARS OF DATA
# df_met_long <- df_date_match %>%
#   gather(key = 'variable', value = 'prediction', -datetime, na.rm = FALSE) %>%
#   mutate(year = format(as.Date(datetime, format="%Y-%m-%d %H:%M"),"%Y")) %>%
#   mutate(doy = as.numeric(strftime(datetime, format = "%j"))) %>%
#   mutate(hour = hour(datetime)) %>%
#   filter(datetime >= '2016-01-01 00:00') %>%
#   filter(datetime < '2023-01-01 00:00')
#
# # ASSIGN ENSEMBLE MEMBER NUMBER FOR EACH YEAR
# df_met_long$parameter <- NA
# df_met_long$parameter <- ifelse(df_met_long$year == '2016',1,df_met_long$parameter)
# df_met_long$parameter <- ifelse(df_met_long$year == '2017',2,df_met_long$parameter)
# df_met_long$parameter <- ifelse(df_met_long$year == '2018',3,df_met_long$parameter)
# df_met_long$parameter <- ifelse(df_met_long$year == '2019',4,df_met_long$parameter)
# df_met_long$parameter <- ifelse(df_met_long$year == '2020',5,df_met_long$parameter)
# df_met_long$parameter <- ifelse(df_met_long$year == '2021',6,df_met_long$parameter)
# df_met_long$parameter <- ifelse(df_met_long$year == '2022',7,df_met_long$parameter)
#
# ## ADD EXTRA COLUMNS
# df_met_long$site_id <- 'fcre'
# df_met_long$family <- 'ensemble'
# df_met_long$longitude <- '-79.83722'
# df_met_long$latitude <- '37.30315'
# df_met_long$forecast_valid <- NA
#
# ## ASSIGN HEIGHT DESCRIPTIONS FOR EACH VARIABLE
# df_met_long$height <- NA
# df_met_long$height <- ifelse(df_met_long$variable == 'northward_wind','10 m above ground',df_met_long$height)
# df_met_long$height <- ifelse(df_met_long$variable == 'eastward_wind','10 m above ground',df_met_long$height)
# df_met_long$height <- ifelse(df_met_long$variable == 'air_pressure','surface',df_met_long$height)
# df_met_long$height <- ifelse(df_met_long$variable == 'air_temperature','2 m above ground',df_met_long$height)
# df_met_long$height <- ifelse(df_met_long$variable == 'relative_humidity','2 m above ground',df_met_long$height)
# df_met_long$height <- ifelse(df_met_long$variable == 'precipitation_flux','surface',df_met_long$height)
# df_met_long$height <- ifelse(df_met_long$variable == 'surface_downwelling_longwave_flux_in_air','surface',df_met_long$height)
# df_met_long$height <- ifelse(df_met_long$variable == 'surface_downwelling_shortwave_flux_in_air','surface',df_met_long$height)
#
#
# ## CREATE BASE DATE TABLE FOR JOINING MET DATA
# date_store <- df_met_long %>%
#   select(hour,doy) %>%
#   distinct(doy, hour, .keep_all = TRUE)
#
# ## CREATE TABLE TO STORE DATE INFO FOR JOINING
# future_dates <- seq.Date(as.Date('2023-03-26'),as.Date('2024-03-25'),by='day')
# doy_match <- strftime(future_dates, format = "%j")
# date_match <- data.frame(new_dates = future_dates, doy = as.numeric(strftime(future_dates, format = "%j")))
#
#
# ## JOIN MET DATA AND EXTRA DATE COLUMNS TO CREATE ANNUAL CLIMATE TABLE
# df_met_join <- date_store %>%
#   right_join(df_met_long, by=c('doy','hour')) %>%
#   right_join(date_match,by='doy') %>%
#   mutate(datetime = as.POSIXct(paste0(new_dates,' ',hour,':00'), format = '%Y-%m-%d %H:%M', tz = 'UTC')) %>%
#   mutate(reference_datetime = as.POSIXct(paste0(future_dates[1],' ','00:00'), format = '%Y-%m-%d %H:%M', tz = 'UTC')) %>%
#   mutate(start_date = as.Date(reference_datetime)) %>%
#   mutate(horizon = as.numeric(difftime(datetime,reference_datetime,units = 'hours'))) %>%
#   select(site_id,prediction,variable, height, horizon, parameter, family, reference_datetime, start_date, forecast_valid, datetime, longitude, latitude) %>%
#   arrange(datetime)
#
#
# # FILL IN MISSING DATA WITH AVERAGES FROM OTHER E-MEMBERS
# library(zoo)
# df_nan_fix <- df_met_join %>%
#   group_by(variable, datetime) %>%
#   mutate(prediction = na.aggregate(prediction)) %>%
#   ungroup()
#
# #df_nan_fix$datetime <- as.Date(df_nan_fix$datetime, "%m/%d/%Y %H:%M")
# df_nan_fix <- df_nan_fix %>% filter(!is.na(parameter))
#
# ## SAVE TABLE TO S3 STORAGE
# s3_write <- arrow::s3_bucket("drivers/noaa/clim-annual/stage2/parquet/0", endpoint_override = "s3.flare-forecast.org")
# arrow::write_dataset(df_nan_fix, s3_write, format = "parquet", partitioning = c("start_date", "site_id"), hive_style = FALSE)
