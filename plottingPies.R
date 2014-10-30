##### Define main functions #####
# R fonction
as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

# fonction that turns one 'overall' pie, and a few specific pies according to colNameY
camemberize <- function(ent, colNameX, colNameY, labs, cols, output=F){
  nb <- length(labs)
  
  ent$exit <- ent[,colNameX]
  for (n in 1:nb){
    ent$exit[ent[,colNameX]>=((n-1)*100/nb) & ent[,colNameX]<(n*100/nb)] <- n
    if(n==nb){
      ent$exit[ent[,colNameX]>=((n-1)*100/nb) & ent[,colNameX]<=(n*100/nb)] <- n
    }
  }

  #overall
  filen <- paste(colNameX, 'Overall', '.png', sep='')
  if (output == F){
    png(filename=filen)
  }
  pie(table(ent$exit), main='Overall', col=cols[as.numeric.factor(unique(data.frame(table(ent$exit))$Var1))], labels=labs[as.numeric.factor(unique(data.frame(table(ent$exit))$Var1))])
  if (output == F){
    dev.off()
  }

  for (Yvar in unique(ent[,colNameY])){
    filen <- paste(colNameX, colNameY, Yvar, '.png', sep='')
    if (output == F){
      png(filename=filen, bg = "transparent")
    }
    pie(table(ent$exit[ent[,colNameY]==Yvar]), main=Yvar, 
        col=cols[as.numeric.factor(unique(data.frame(table(ent$exit[ent[,colNameY]==Yvar]))$Var1))],
        labels=labs[as.numeric.factor(unique(data.frame(table(ent$exit[ent[,colNameY]==Yvar]))$Var1))])
    if (output == F){
      dev.off()
    }
  }
}

# each x is going to have different names/ colors
select_labcol <- function(colNameX){
  #this function tells the number of categories that we have,
  #their names and colors
  
  cols <- c(rgb(.80,.40,0),
            rgb(.90,.60,0),
            rgb(.35,.70,.90), 
            rgb(0,.45,.70)) #vermillion orange light/dark blue
  
  if (colNameX == "probe.thought.focus.focusedDoing"){
    labs <- c('Totally Off-task', 'Mostly Off-task', 'Mostly On-task', 'Totally On-task')}
  if (colNameX == "probe.thought.focus.awareWandering"){
    labs <- c('Totally unaware', 'Mostly Unaware', 'Mostly aware', 'Totally aware')}
  if (colNameX == "probe.thought.surround"){
    labs <- c('Not aware', 'A bit aware', 'Mostly aware', 'Totally aware')}
  
  if (colNameX == "probe.thought.words" | colNameX == "probe.thought.auditory" | colNameX == "probe.thought.visual"){
    cols <- c(rgb(.80,.40,0),
              rgb(.5,.90,1), 
              rgb(.35,.70,.90), 
              rgb(0,.45,.70))} #vermillion pale/light/dark blue
  if (colNameX == "probe.thought.words"){
    labs <- c('No words', 'Abstract words', 'Some words', 'All words')}
  if (colNameX == "probe.thought.auditory"){
    labs <- c('No sounds', 'Abstract sounds', 'Some sounds', 'All sounds')}
  if (colNameX == "probe.thought.visual"){
    labs <- c('No images', 'Abstract images', 'Some images', 'All images')}
  
  return(cbind(cols, labs))
}

# select pies according to p.value
print_select <- function(pval_lim, colNameX, colNameY, suj, output=F){
  entry <- data[data[,colNameX]!=-1 & (data$profile_id %in% suj) & data$type=='probe' & data$probe.selfInitiated=='False',]
  
  ### to get a p-value
  # 1) have at least 4 probes 
  # 2) X must not be constant (soit sd(X)>0 length(X)>3)
  
  if (length(entry[,colNameX])>3 & sd(entry[,colNameX])>0){
    if (length(suj)>1){
      h <- aggregate(entry[,colNameX], list(suj=entry$profile_id, cond=entry[,colNameY]), mean)
      i <- evalq(aggregate(x, list(cond=cond), mean), h)
      l <- aov(x ~ cond, h); summary(l)}
    
    if (length(suj)==1){
      l <- aov(entry[,colNameX] ~ entry[,colNameY]); summary(l)
    }
    if (summary(l)[[1]][["Pr(>F)"]][[1]] < pval_lim){
      lc <- select_labcol(colNameX)
      camemberize(entry, colNameX, colNameY, lc[,2], lc[,1], output)
    }
  }
  else {
    print('Not enough data')
  }
}

##### Load & Prepare Data #####
#loading data from my desktop
setwd("/home/bastian/App_Plot_Results")
data <- read.table(file="results-latest2.csv", sep="\t", header=T) #the names of the columns are in the txt file
summary(data)

# categorize the continuous variables
catX4 <- c(9:14);colnames(data[,catX4]) #relevant columns for x
for (cNX in colnames(data[,catX4])){
  ncNX <- paste('cat', cNX, sep='.'); data[,ncNX] <- data[,cNX]
  data[,ncNX][data[,ncNX]!=-999] <- ceiling(data[,cNX][data[,cNX]!=-999]/25)
  data[,ncNX][data[,ncNX]==0] <- 1
  data[,ncNX][data[,cNX]==-1] <- -1
  data[,ncNX] <- factor(data[,ncNX])
}
catX5 <- c(22:23);colnames(data[,catX5]) #relevant columns for x
for (cNX in colnames(data[,catX5])){
  ncNX <- paste('cat', cNX, sep='.'); data[,ncNX] <- data[,cNX]
  data[,ncNX][data[,ncNX]!=-999] <- ceiling(data[,cNX][data[,cNX]!=-999]/20)
  data[,ncNX][data[,ncNX]==0] <- 1
  data[,ncNX] <- factor(data[,ncNX])
}
catX7 <- c(21,22);colnames(data[,catX7]) #relevant columns for x
for (cNX in colnames(data[,catX7])[1]){
  ncNX <- paste('cat', cNX, sep='.'); data[,ncNX] <- data[,cNX]
  data[,ncNX][data[,ncNX]!=-999] <- ceiling(data[,cNX][data[,cNX]!=-999]/14.28571)
  data[,ncNX][data[,ncNX]==0] <- 1
  data[,ncNX][data[,cNX]==100] <- 7
  data[,ncNX] <- factor(data[,ncNX])
}

# and give them proper names
levels(data$cat.probe.thought.focus.focusedDoing)   <- c(-999, 'Totally Off-task', 'Mostly Off-task', 'Mostly On-task', 'Totally On-task')
levels(data$cat.probe.thought.focus.awareWandering) <- c(-999, -1, 'Totally unaware', 'Mostly Unaware', 'Mostly aware', 'Totally aware')
levels(data$cat.probe.thought.surround)             <- c(-999, 'Not aware', 'A bit aware', 'Mostly aware', 'Totally aware')
levels(data$cat.probe.thought.words)                <- c(-999, 'No words', 'Abstract words', 'Some words', 'All words')
levels(data$cat.probe.thought.auditory)             <- c(-999, 'No sounds', 'Abstract sounds', 'Some sounds', 'All sounds')
levels(data$cat.probe.thought.visual)               <- c(-999, 'No images', 'Abstract images', 'Some images', 'All images')
levels(data$cat.probe.context.interaction)          <- c(-999, 'No interaction', 'With One Person Here', 'With One Person Far Away', 'With Many Persons Here', 'With Many Persons Far Away')
levels(data$cat.probe.context.people)               <- c(-999, 'Alone', '1 Person Around', '2-5 Persons Around', '6-15 Persons Around', 'More than 15 Persons Around')
levels(data$cat.probe.context.noise)                <- c(-999, 'One person speaking', 'Many persons speaking', 'Music', 'TV Radio', 'Human-related Noise', 'Non-Human-related Noise', 'Silence')

#now we have one continuous variable (for the anovas, as X)
#and one categorized variable (as Y)

#finally let's get the day this all happened
data$day <- factor(weekdays(as.Date(data$systemDate,'%Y-%m-%d')))
levels(data$day) <- c('Sunday', 'Thursday', 'Monday', 'Tuesday', 'Wednesday', 'Saturday', 'Friday')
data$day <- relevel(data$day, 'Sunday');    data$day <- relevel(data$day, 'Saturday');  data$day <- relevel(data$day, 'Friday'); data$day <- relevel(data$day, 'Thursday')
data$day <- relevel(data$day, 'Wednesday'); data$day <- relevel(data$day, 'Tuesday');   data$day <- relevel(data$day, 'Monday')

##### Review available Xs and Ys, and Get the (relevant) figures #####
# available variables
head(data)
possibleY  <- c(15,18,24:26,30:33);colnames(data[,possibleY]) #relevant factors for y
# 6 main variables that vary accross 9 parameters -> about 50 possibilities 

# this generates all the relevant effects of all possible Y on all possible X
# takes as argument: p-value limit, subjects ('all' or 1,2,3,etc.), 
# and out = F: no display but printed, out = T: display not printed

get_figures <- function(pval_lim, s, out=F){
  if (s == 'all'){
    suj <- data.frame(table(data$profile_id))[,1] #all subjects
  }
  if (s != 'all'){
    suj <- data.frame(table(data$profile_id))[s,1]
  }
  
  for (colNameY in colnames(data[,possibleY])){
    
    possibleX <- c(9:14);colnames(data[,possibleX]) #X by default  
    
    #special cases where redundancy might be annoying
    if (colNameY=='cat.probe.thought.focus.focusedDoing' | colNameY=='cat.probe.thought.focus.awareWandering'){
      possibleX <- c(11:14);colnames(data[,possibleX])}
    if (colNameY=="cat.probe.thought.surround"){
      possibleX <- c(12:14);colnames(data[,possibleX])}
    
    for (colNameX in colnames(data[,possibleX])){
      print_select(pval_lim, colNameX, colNameY, suj, out)
    }
  }
}

get_figures(.15, 'all', out=F)
# this one output all the relevant pies at a p<.15 threshold on the anova X ~ Y
