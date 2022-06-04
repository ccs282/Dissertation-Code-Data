# set working directory
getwd()
setwd("C:/Users/jonas/OneDrive - London School of Economics/Documents/LSE/GY489_Dissertation/LETS GO/Data")

# install packages
#install.packages("readr")
update.packages(ask = FALSE)

# load packages
library(readr)

# import data
data <- read.csv("Data_new.csv")

#### prep data

# add time variables
data$year <- as.integer(data$Date/10000)
data$month <- as.integer((data$Date - data$year*10000)/100)
data$day <- as.integer(data$Date - data$year*10000 - data$month*100)

data$trading_date <- c(1:length(data$year))

# drop observations
data1 <- subset(data, year >= 2008)

# group explanatory variables

##### returns

reg1 <- lm(EUA_Settle ~ Oil_Last + Coal_Last + Gas_Last, data1)
summary(reg1)

#coeftest(reg1, vcov = vcovHC(lmAPI, "HC1"))