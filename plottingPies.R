#loading the data (here from my desktop)
setwd("C:/Users/Mikael/Desktop")
data <- read.table(file="fakedataApp.txt", header=T) #the names of the columns are in the txt file

# create a function that plot pies and takes an variable argument x (that can be mindwandering, innerspeech, controllability of thought, etc.)
# and an argument of colors to be plotted
plotpie <- function(x, colors){
  par(mfrow=c(1,1))
  pie(table(x[is.na(x)==F]), col=colors, labels='', main='Overall') #a big pie in the middle: grand average
  #surrounded by little pies according to the different places
  par(mfrow=c(2,2))
  pie(table(x[is.na(x)==F & data$Location=='Home']), col=colors, labels='', main='Home')
  pie(table(x[is.na(x)==F & data$Location=='Work']), col=colors, labels='', main='Work')
  pie(table(x[is.na(x)==F & data$Location=='Outside']), col=colors, labels='', main='Outside')
  pie(table(x[is.na(x)==F & data$Location=='Public']), col=colors, labels='', main='Public Space')
}

#first example: proportion off-task
x <- data$Mindwandering
colors <- c(rgb(0,1,0),rgb(.4,1,.4),rgb(.8,.8,.8),rgb(1,.4,.4),rgb(1,0,0))
plotpie(x, colors)

#second example: proportion inner speech
x <- data$Innerspeech
colors <- c(rgb(.6,.6,.6),rgb(.6,.6,1),rgb(.4,.4,1),rgb(.0,.0,1))
plotpie(x, colors)


