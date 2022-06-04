# set working directory
getwd()
setwd("C:/Users/jonas/OneDrive - London School of Economics/Documents/LSE/GY489_Dissertation/LETS GO/Dissertation-Code-Data")

# packages
packages <- c("readr", "readxl", "ggplot2", "dplyr", "tidyr", "estimatr", "dynlm")
install.packages(packages)
update.packages(ask = FALSE)

library(readr)
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(estimatr)
library(zoo)
library(dynlm)

installed.packages()
# import data
data <- read.csv("Data_new.csv")

#### prep data

# add time variables
data$year <- as.integer(data$Date / 10000)
data$month <- as.integer((data$Date - data$year * 10000) / 100)
data$day <- as.integer(data$Date - data$year * 10000 - data$month * 100)

data$trading_date <- c(seq_len(length(data$year)))

# drop observations
data1 <- subset(data, year >= 2008)

# group explanatory variables

# create lags
max_lag <- 100

for (i in 1:max_lag) {
}

##### returns

reg1 <- lm(EUA_Settle ~ Oil_Last + Coal_Last + Gas_Last + Elec_Last + GSCI_Last + VIX_Last + STOXX_Last + Diff_BAA_AAA+ CER_Last + ecb_spot_3m, data1) # nolint
summary(reg1)

# stata robust SE
reg2 <- lm_robust(EUA_Settle ~ Oil_Last + Coal_Last + Gas_Last + Elec_Last + GSCI_Last + VIX_Last + STOXX_Last + Diff_BAA_AAA+ CER_Last + ecb_spot_3m, se_type = "stata", data1) # nolint
summary(reg2)




#coeftest(reg1, vcov = vcovHC(lmAPI, "HC1"))