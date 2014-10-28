# R fonction
as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

# fonction that turns one 'overall' pie, and a few specific pies according to Yplot
camemberize <- function(ent, Xplot, Yplot, labs, cols, output=F){
  nb <- length(labs)
  
  ent$exit <- ent[,Xplot]
  for (n in 1:nb){
    ent$exit[ent[,Xplot]>=((n-1)*100/nb) & ent[,Xplot]<(n*100/nb)] <- n
    if(n==nb){
      ent$exit[ent[,Xplot]>=((n-1)*100/nb) & ent[,Xplot]<=(n*100/nb)] <- n
    }
  }

  #overall
  filen <- paste(Xplot, 'Overall', '.png', sep='')
  if (output == F){
    png(filename=filen)
  }
  pie(table(ent$exit), main='Overall', col=cols[as.numeric.factor(unique(data.frame(table(ent$exit))$Var1))], labels=labs[as.numeric.factor(unique(data.frame(table(ent$exit))$Var1))])
  if (output == F){
    dev.off()
  }

  for (Yvar in unique(ent[,colNameY])){
    filen <- paste(Xplot, Yvar, '.png', sep='')
    if (output == F){
      png(filename=filen)
    }
    pie(table(ent$exit[ent[,colNameY]==Yvar]), main=Yvar, 
        col=cols[as.numeric.factor(unique(data.frame(table(ent$exit[ent[,colNameY]==Yvar]))$Var1))],
        labels=labs[as.numeric.factor(unique(data.frame(table(ent$exit[ent[,colNameY]==Yvar]))$Var1))])
    if (output == F){
      dev.off()
    }
  }
}

#loading data from my desktop
setwd("/home/bastian")
data <- read.table(file="results-latest2.csv", sep="\t", header=T) #the names of the columns are in the txt file
summary(data)

# available variables
possibleX <- c(9:14, 21:23) #relevant columns for x
possibleY  <- c(6,15:23) #relevant factors for y
head(data[,possibleX])
head(data[,possibleY])

### variables are in numbers, we must categorize them
#vis/aud/word/surr/aw/(mw) have 4 possibilites
#people 5 possibilities : 0 / 1 / 2-5 / 6-15 / >15
#noise 7 possibilities 1speaking manyspeaking music tv  human non human silence
#interact 5:  0 / 1 here / 1 far / many here / many far

### 
# select 1 subject, 1 x, 1 y #here first subject, focus according to location
suj <- data.frame(table(data$profile_id))[1,1]
#colNameX <- 'probe.thought.focus.focusedDoing'
colNameX <- 'probe.thought.words'
colNameY <- 'probe.context.location.1'
entry <- data[data$profile_id==suj & data$type=='probe' & data$probe.selfInitiated=='False',]

# each x is going to have different names/ colors
if (colNameX == "probe.thought.focus.focusedDoing"){
  labs <- c('Totally Off-task', 'Mostly Off-task', 'Mostly On-task', 'Totally On-task')
  cols <- c(rgb(.80,.40,0),
            rgb(.90,.60,0),
            rgb(.35,.70,.90), 
            rgb(0,.45,.70)) #vermillion orange light/dark blue
}
if (colNameX == "probe.thought.surround"){
  labs <- c('Not aware', 'A bit aware', 'Mostly aware', 'Totally aware')
  cols <- c(rgb(.80,.40,0),
            rgb(.90,.60,0),
            rgb(.35,.70,.90), 
            rgb(0,.45,.70)) #vermillion orange light/dark blue
}
if (colNameX == "probe.thought.words"){
  labs <- c('No words', 'Abstract words', 'Some words', 'All words')
  cols <- c(rgb(.80,.40,0),
            rgb(.5,.90,1), 
            rgb(.35,.70,.90), 
            rgb(0,.45,.70)) #vermillion orange light/dark blue
}

camemberize(entry, colNameX, colNameY, labs, cols)
#outputs the pies
