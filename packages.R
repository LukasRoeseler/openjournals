### Install packages

list.of.packages <- c("ggplot2", "psych", "devtools", "sjrdata", "shinylive", "httpuv", "RCurl", "markdown")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# devtools::install_github("ikashnitsky/sjrdata")

# load packages
library(shiny)
library(DT)
library(ggplot2)
library(psych)
library(devtools)
library(sjrdata)
library(ggplot2)
library(ggpubr)
library(openxlsx)
library(RCurl)
library(markdown)