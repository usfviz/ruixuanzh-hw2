# To run this code, use the dataset downloaded from WB (on slack)
library(shiny)
library(googleVis)
library(countrycode)
library(tidyr)
library(dplyr)
library(ggplot2)

# setwd("/Users/Ruixuan/Documents/01infoVisual/hw/hw2/googlevis/")


life <- read.csv("API_SP/API_SP.DYN.LE00.IN_DS2_en_csv_v2.csv")
life.df <- life[, -c(3,4)]
# imputation
for (col in 3: 57){
  life.df[is.na(life.df[,col]), col] = mean(life.df[, col], na.rm=TRUE)
}
continent.df <- read.csv("API_SP/Metadata_Country_API_SP.DYN.LE00.IN_DS2_en_csv_v2.csv")
tmp.df <- merge(life.df, continent.df, by.x = "Country.Code", by.y = "Country.Code")
tmp.df <- tmp.df[, -c(58, 59, 61, 62, 63)]
long.life <- gather(tmp.df, year, value, X1960: X2014)

# preprocessing the second dataset
fert <- read.csv("API_SP-2/API_SP.DYN.TFRT.IN_DS2_en_csv_v2.csv")
fert.df <- fert[, -c(3,4)]
# imputation
for (col in 3: 57){
  fert.df[is.na(fert.df[,col]), col] = mean(fert.df[, col], na.rm=TRUE)
}
# merge with continent
tmp.df2 <- merge(fert.df, continent.df, by.x = "Country.Code", by.y = "Country.Code")
tmp.df2 <- tmp.df2[, -c(58, 59, 61, 62, 63)]
# short data to long
long.fert <- gather(tmp.df2, year, value, X1960: X2014)

# preprocessing the third dataset
pop <- read.csv("API_SP.POP.TOTL_DS2_en_csv_v2.csv")
pop.df <- pop[, -c(3,4)]
# imputation
for (col in 3: 57){
  pop.df[is.na(pop.df[,col]), col] = mean(pop.df[, col], na.rm=TRUE)
}
tmp.df <- merge(pop.df, continent.df, by.x = "Country.Code", by.y = "Country.Code")
tmp.df <- tmp.df[, -c(58, 59, 61, 62, 63)]
long.pop <- gather(tmp.df, year, value, X1960: X2014)

# final dataset
long.df <- data.frame(long.life, fertility = long.fert$value, population = long.pop$value)
long.df <- long.df[!long.df$Region == "",]
long.df$year <-  as.integer(substr(long.df$year, start = 2, stop = 5))
colnames(long.df) <- c("Country.Code",  "Country.Name", "Region", "Year", "Life Expectancy", "Fertility", "Population")


# googleVis R interface to Google charts API, charts are displayed via R HTTP help server
shinyServer(function(input, output, session){
  defaultColors <- c("#3366cc", "#dc3912", "#ff9900", "#109618", "#990099", "#0099c6", "#dd4477")
  # output$bubble <- renderGvis({
  #   gvisBubbleChart(long.df, idvar="Country.Name",
  #                   xvar="value", yvar="fertility",
  #                   colorvar="Region", sizevar="population",
  #                   options=list(title = "An example of Bubble Chart",
  #                                hAxis='{title: "Life Expectancy", minValue:10,  maxValue:90}',
  #                                vAxis='{title: "Fertility rate"}')
  #   )})
  
  output$bubble <- renderGvis({
    gvisMotionChart(long.df, idvar="Country.Name",
                    timevar = "Year",
                    xvar="Life Expectancy", yvar="Fertility",
                    colorvar="Region", sizevar="Population",
                    options=list(title = "GapMinder GoogleVis Motion Chart",
                                 hAxis='{title: "Life Expectancy", minValue:10,  maxValue:90}',
                                 vAxis='{title: "Fertility Rate"}'
                                 # ,state = '{"colorOption":['#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99','#b15928']}'
                                 )
    )})

})
