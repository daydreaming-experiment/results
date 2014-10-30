##### Load & Prepare Data #####
#loading data from my desktop
setwd("C:/Users/Mikael/Downloads")
data <- read.table(file="results-latest2.csv", sep="\t", header=T) #the names of the columns are in the txt file
summary(data)

data$day <- factor(weekdays(as.Date(data$systemDate,'%Y-%m-%d')))
levels(data$day) <- c('Sunday', 'Thursday', 'Monday', 'Tuesday', 'Wednesday', 'Saturday', 'Friday')
data$day <- relevel(data$day, 'Sunday');    data$day <- relevel(data$day, 'Saturday');  data$day <- relevel(data$day, 'Friday'); data$day <- relevel(data$day, 'Thursday')
data$day <- relevel(data$day, 'Wednesday'); data$day <- relevel(data$day, 'Tuesday');   data$day <- relevel(data$day, 'Monday')

cl <- '#EBFBFF' #text/axes color

# FIRST PLOT: focus en fonction du day
#png(filename='1_focus_according_to_day.png', bg = "transparent", res=500)
svg(filename='1_focus_according_to_day.svg', bg = "transparent")
h <- evalq(aggregate(100-probe.thought.focus.focusedDoing, list(day=day), mean), data[data$type=='probe' & data$probe.selfInitiated=='False',])
plot(h$x, type='b', ylim=c(0,100), lwd=4, ylab='% Mind Wandering', 
     xlab='Day of the week', xaxt="n", yaxt="n", bty='n',
     col=cl, col.lab=cl, cex.lab=2, pch=c(8,1,1,1,8,1,1))
axis(1, lab=F, col=cl, col.axis=cl)
text(axTicks(1), par("usr")[3] - 5, srt=45, adj=1,
     labels=c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
     xpd=T, cex=1.5, col=cl)
axis(2, cex.axis=1.5, col=cl, col.axis=cl, las=1)
abline(h=50, lty=2, col=cl)
pavg <- mean(100-data[data$type=='probe' & data$probe.selfInitiated=='False',]$probe.thought.focus.focusedDoing)
abline(h=pavg, lty=3, col=cl, lwd=2)
text(2.2, pavg-2.5, "People's average", cex=1.5, col=cl)
dev.off()


# SECOND PLOT: overall awareness
# categorize the continuous variables (awareness)
catX4 <- c(9:14);colnames(data[,catX4]) #relevant columns for x
for (cNX in colnames(data[,catX4])){
  ncNX <- paste('cat', cNX, sep='.'); data[,ncNX] <- data[,cNX]
  data[,ncNX][data[,ncNX]!=-999] <- ceiling(data[,cNX][data[,cNX]!=-999]/25)
  data[,ncNX][data[,ncNX]==0] <- 1
  data[,ncNX][data[,cNX]==-1] <- -1
  data[,ncNX] <- factor(data[,ncNX])
}
levels(data$cat.probe.thought.focus.awareWandering) <- c(-999, -1, 'Totally Unaware', 'Mostly Unaware', 'Mostly Aware', 'Totally Aware')

png(filename='2_overall_awareness.png', bg = "transparent", res=500)
svg(filename='2_overall_awareness.svg', bg = "transparent")
h <- table(droplevels(data[data$cat.probe.thought.focus.awareWandering!=-999 
           & data$cat.probe.thought.focus.awareWandering!=-1,]$cat.probe.thought.focus.awareWandering))
pie(h, col=c('#EBFBFF','#C3D1D4', '#9BA6A8', '#737B7D'))
par(fg=cl)
pie(h, col=c('#99017B', '#E23E99', '#F994B1', '#FCCFCB'), cex=2)
dev.off()

#this plot suggest that there is mind wandering to judge up to 80% focus (see under)
hist(data[data$probe.thought.focus.awareWandering!=-999
     & data$probe.thought.focus.awareWandering!=-1,]$probe.thought.focus.focusedDoing)

# THIRD PLOT: words, images sounds for focus (80-100) and mind wandering (0:80)
#<80 TRUE if mind wandering
h <- evalq(aggregate(probe.thought.words, list(mw=probe.thought.focus.focusedDoing<=80), mean), data[data$type=='probe' & data$probe.selfInitiated=='False',])
i <- evalq(aggregate(probe.thought.visual, list(mw=probe.thought.focus.focusedDoing<=80), mean), data[data$type=='probe' & data$probe.selfInitiated=='False',])
j <- evalq(aggregate(probe.thought.auditory, list(mw=probe.thought.focus.focusedDoing<=80), mean), data[data$type=='probe' & data$probe.selfInitiated=='False',])

png(filename='3_phenomenology.png', bg = "transparent", res=500)
svg(filename='3_phenomenology.svg', bg = "transparent")
g <- cbind(h$x,i$x,j$x); dimnames(g) <- list(c('Focused Mind', 'Wandering Mind'), c('% Words', '% Images', '% Sounds'))
barplot(t(g), beside=T, ylim=c(0,100), col=c('#91DB56', '#DBC256', '#DB5E56'), legend=F, yaxt='n',
        xaxt='n', border=F)
axis(1, at=c(2.5, 6.5), lab=rownames(g), cex.axis=1.8, col=cl, col.axis=cl)
axis(2, cex.axis=1.5, col=cl, col.axis=cl, las=1)
par(fg=cl)
legend('topleft', colnames(g), fill=c('#91DB56', '#DBC256', '#DB5E56'), border=F, bty='n', cex=2)
dev.off()


# FOURTH PLOT: SURROUNDINGS ACCORDING TO LOCATION
png(filename='4_surroundingsLocation.png', bg = "transparent", res=500)
svg(filename='4_surroundingsLocation.svg', bg = "transparent")
data$probe.context.location.1 <- relevel(data$probe.context.location.1, 'Commuting')
data$probe.context.location.1 <- relevel(data$probe.context.location.1, 'Work')
data$probe.context.location.1 <- relevel(data$probe.context.location.1, 'Outside')
data$probe.context.location.1 <- relevel(data$probe.context.location.1, 'Home')
data$probe.context.location.1 <- relevel(data$probe.context.location.1, 'Public place')
h <- evalq(aggregate(probe.thought.surround, list(loc=probe.context.location.1), mean), data[data$type=='probe' & data$probe.selfInitiated=='False',])
barplot(h$x, beside=T, ylim=c(0,100), yaxt='n', xaxt='n', ylab='% Aware of Surroundings', 
        cex.lab=2, col.lab=cl, xlab='Locations', border=F,
        col=c('#F67088', '#CE8F31', '#96A331','#32B165', '#A38CF4'))
axis(1, at=c(.7, 1.9, 3.1, 4.3, 5.5) , lab=h$loc, cex.axis=1, col=cl, col.axis=cl)
axis(2, cex.axis=1.5, col=cl, col.axis=cl, las=1)
dev.off()





# FIFTH PLOT: SURROUNDINGS ACCORDING TO NB PEOPLE AROUND
# categorize the continuous variables
catX5 <- c(22:23);colnames(data[,catX5]) #relevant columns for x
for (cNX in colnames(data[,catX5])){
  ncNX <- paste('cat', cNX, sep='.'); data[,ncNX] <- data[,cNX]
  data[,ncNX][data[,ncNX]!=-999] <- ceiling(data[,cNX][data[,cNX]!=-999]/20)
  data[,ncNX][data[,ncNX]==0] <- 1
  data[,ncNX] <- factor(data[,ncNX])
}
levels(data$cat.probe.context.interaction)          <- c(-999, 'No interaction', 'With One Person Here', 'With One Person Far Away', 'With Many Persons Here', 'With Many Persons Far Away')
levels(data$cat.probe.context.people)               <- c(-999, '0', '1', '2-5', '6-15', '>15')


png(filename='5_surroundingsPeople.png', bg = "transparent", res=500)
svg(filename='5_surroundingsPeople.svg', bg = "transparent")
h <- evalq(aggregate(probe.thought.surround, list(loc=cat.probe.context.people), mean), data[data$type=='probe' & data$probe.selfInitiated=='False',])
barplot(h$x, beside=T, ylim=c(0,100), yaxt='n', xaxt='n', ylab='% Aware of Surroundings', 
        cex.lab=2, col.lab=cl, xlab='Number of People Around', border=F,
        col=c('#EBFBFF', '#CEDDE0', '#B2BFC2','#96A1A3', '#7a8385'))
barplot(h$x, beside=T, ylim=c(0,100), yaxt='n', xaxt='n', ylab='% Aware of Surroundings', 
        cex.lab=2, col.lab=cl, xlab='Number of People Around', border=F,
        col=c('#8A0179', '#CD238E', '#F768A1', '#FAABB8', '#FCD7D3'))
#barplot(h$x, beside=T, ylim=c(0,100), yaxt='n', xaxt='n', ylab='% Aware of Surroundings', 
#        cex.lab=1.5, col.lab=cl, xlab='Number of People Around', border=F,
#        col=c('#FCD7D3', '#FAABB8', '#F768A1', '#CD238E', '#8A0179'))
axis(1, at=c(.7, 1.9, 3.1, 4.3, 5.5) , lab=h$loc, cex.axis=1.9, col=cl, col.axis=cl)
axis(2, cex.axis=1.5, col=cl, col.axis=cl, las=1)
dev.off()



