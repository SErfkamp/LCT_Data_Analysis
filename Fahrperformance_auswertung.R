library(readxl)
library(ggplot2)
library(coin)
library(lme4)
library(lmerTest)
library(agricolae)
library(psych)


# Pfade
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

path <-  paste(os,"OneDrive/Thesis/Studie/Auswertung.xlsx",sep="")
data <- read_excel(path, sheet = "LCTAnalyzer_output")
interactions <- read_excel(path, sheet = "Interactions")
interactions <- interactions[interactions$Proband!=1,]
data <- data[data$Valid==1,]

dataAdj <- data[!data$Proband %in% data$Proband[data$MissedOrWrong>0],]

dataCorrected <- subset(data,select=-c(Mdev))
dataCorrected$Mdev <- dataCorrected$MDevCorrected
dataCorrected <- subset(dataCorrected,select=-c(MDevCorrected))

treatments <- c("base","user", "drive", "interaction", "track")
vars <- c("Mdev", "SDdev")#, "MSteer", "SDSteer", "MSpeed")

# -------------------------------------------------------------
# General #
# -------------------------------------------------------------

generalRes <- data.frame()
generalResAdj <- data.frame()
generalResCorrected <- data.frame()

for(i in 1:length(treatments)) {
  treatment <- treatments[i]
  treatTemp <- subset(data,Treatment==treatment)
  treatTempAdj <- subset(dataAdj,Treatment==treatment)
  treatTempCorrected <- subset(dataCorrected,Treatment==treatment)
  
  row <- i
  
  for(j in 1:length(vars)) {
    test <- describe(as.matrix(treatTemp[vars[j]]))
    testAdj <- describe(as.matrix(treatTempAdj[vars[j]]))
    testCorrected <- describe(as.matrix(treatTempCorrected[vars[j]]))
    
    generalRes[row,j] <- paste("M = ",round(test$mean,2),", SD = ", round(test$sd,2), sep="")
    generalResAdj[row,j] <- paste("M = ",round(testAdj$mean,2),", SD = ", round(testAdj$sd,2), sep="")
    generalResCorrected[row,j] <- paste("M = ",round(testCorrected$mean,2),", SD = ", round(testCorrected$sd,2), sep="")
    
  }
}

# -------------------------------------------------------------
# Test for normality #
# -------------------------------------------------------------

allData <- list(data,dataAdj,dataCorrected)

normalityRes <- data.frame()
for(j in 1:3) {
  
  row <- (j-1)*length(treatments)
  normalityData <- allData[j][[1]]
  
  for(i in 1:length(treatments)) {
    
    row <- row +1
    
    tempNormalityData <- subset(normalityData, Treatment==treatments[i])
    
    test <- shapiro.test(as.matrix(tempNormalityData$Mdev))
    normalityRes[row,1] <- j
    normalityRes[row,2] <- treatments[i]
    
    w <- round(test$statistic,4)
    p <- round(test$p.value,4)
    
    if(p<0.001) {
      sig <- "***"
    } else if (p<0.01) {
      sig <- "**"
    } else if (p<0.05) {
      sig <- "*"
    } else {
      sig <- "n.s."
    }
    
    normalityRes[row,3] <- paste("W = ",w,", p = ", p," ", sig, sep="")
    
  }
}

##########################
# NON - PARAMETRIC TESTS #
##########################

# -------------------------------------------------------------
# Friedman #
# -------------------------------------------------------------

friedmanRes <- data.frame()

test <- friedman(data$Proband, data$Treatment, data$Mdev, console=T)
test2 <- friedman(dataAdj$Proband, dataAdj$Treatment, dataAdj$Mdev, console=T)
test3 <- friedman(dataCorrected$Proband, dataCorrected$Treatment, dataCorrected$Mdev, console=T)

friedmanRes[1,1] <- paste("Chi-Quadrat(",test$statistics$Df,") = ",round(test$statistics$F,4),", p-value = ", round(test$statistics$p.chisq,4), sep="")
friedmanRes[2,1] <- paste("Chi-Quadrat(",test2$statistics$Df,") = ",round(test2$statistics$F,4),", p-value = ", round(test2$statistics$p.chisq,4), sep="")
friedmanRes[3,1] <- paste("Chi-Quadrat(",test3$statistics$Df,") = ",round(test3$statistics$F,4),", p-value = ", round(test3$statistics$p.chisq,4), sep="")

# -------------------------------------------------------------
# Non-Parametric Correlations #
# -------------------------------------------------------------

wilcoxResult <- function (df, treat1, treat2, var) {
  
  tempData <- subset(df,Treatment==treat1 | Treatment==treat2)
  tempData$Treatment <- factor(tempData$Treatment)
  tempData$Proband <- factor(tempData$Proband)
  tempFormula <- as.formula(paste(var," ~ Treatment | Proband",sep=""))
  test <- wilcoxsign_test(tempFormula, tempData, console=T)
  
  z <- round(statistic(test),4)
  p <- round(pvalue(test),4)
  
  #Vorzeichen wird geändert nach Alphabetischer Reihenfolge der Treatments
  if (treat2 < treat1) {
    z <- z * -1
  }
  
  if(p<0.001) {
    sig <- "***"
  } else if (p<0.01) {
    sig <- "**"
  } else if (p<0.05) {
    sig <- "*"
  } else {
    sig <- "n.s."
  }
  
  paste("Z = ",z, ", p-value = ",p, " ",sig,sep="")
}

wilResult <- data.frame()
wilResultAdj <- data.frame()
wilResultCorrected <- data.frame()

for(k in 1:length(vars)) {
  row <- 1
  for(i in 1:(length(treatments)-1)) {
    for(j in (i+1):length(treatments)) {
      if(treatments[i] != treatments[j]) {
        row <- row + 1
        treat1 <- treatments[i]
        treat2 <- treatments[j]
        print(paste(treat1," . " ,treat2))
        var <- vars[k]
        
        wilResult[row,1] <- paste(treat1, " - ", treat2, sep="")
        wilResult[row,k+1] <- wilcoxResult(data, treat1,treat2,var)
        
        wilResultAdj[row,1] <- paste(treat1, " - ", treat2, sep="")
        wilResultAdj[row,k+1] <- wilcoxResult(dataAdj, treat1,treat2,var)
       
         wilResultCorrected[row,1] <- paste(treat1, " - ", treat2, sep="")
        wilResultCorrected[row,k+1] <- wilcoxResult(dataCorrected, treat1,treat2,var)
      }
    }
  }
}

wilResult <- wilResult[2:11,]
wilResultAdj <- wilResultAdj[2:11,]
wilResultCorrected <- wilResultCorrected[2:11,]

names(wilResult) <- c("Untersuchung",vars)
names(wilResultAdj) <- c("Untersuchung",vars)
names(wilResultCorrected) <- c("Untersuchung",vars)


##########################
#### PARAMETRIC TESTS ####
##########################

# -------------------------------------------------------------
# ANOVA #
# -------------------------------------------------------------

anovaRes <- data.frame()

rmaModel <- lmer(Mdev ~ Treatment + (1|Proband), data)
test <- anova(rmaModel)

rmaModel <- lmer(Mdev ~ Treatment + (1|Proband), dataAdj)
test2 <- anova(rmaModel)

rmaModel <- lmer(Mdev ~ Treatment + (1|Proband), dataCorrected)
test3 <- anova(rmaModel)


rmaModel2 <- lmer(SDdev ~ Treatment + (1|Proband), data)
test2 <- anova(rmaModel2)
anovaRes[1,1] <- paste("F(",round(test$NumDF,0),",",round(test$DenDF,0),") = ",round(test$`F value`,4),", p-value = ", round(test$`Pr(>F)`,4), sep="")
anovaRes[1,2] <- paste("F(",round(test2$NumDF,0),",",round(test2$DenDF,0),") = ",round(test2$`F value`,4),", p-value = ", round(test2$`Pr(>F)`,4), sep="")
anovaRes[2,1] <- paste("F(",round(test$NumDF,0),",",round(test$DenDF,0),") = ",round(test$`F value`,4),", p-value = ", round(test$`Pr(>F)`,4), sep="")
anovaRes[3,1] <- paste("F(",round(test$NumDF,0),",",round(test$DenDF,0),") = ",round(test$`F value`,4),", p-value = ", round(test$`Pr(>F)`,4), sep="")

# -------------------------------------------------------------
# Parametric Correlations #
# -------------------------------------------------------------

tTestResult <- function (data, treat1, treat2, var) {
  
  tempData <- subset(data,Treatment==treat1 | Treatment==treat2)
  tempFormula <- as.formula(paste("tempData$",var," ~ tempData$Treatment",sep=""))
  
  test <- t.test(tempFormula, paired = T)
 
  df <- round(test$parameter,0)
  z <- round(test$statistic,4)
  p <- round(test$p.value,4)
  
  #Vorzeichen wird geändert nach Alphabetischer Reihenfolge der Treatments
  if (treat2 < treat1) {
    z <- z * -1
  }
  
  if(p<0.001) {
    sig <- "***"
  } else if (p<0.01) {
    sig <- "**"
  } else if (p<0.05) {
    sig <- "*"
  } else {
    sig <- "n.s."
  }
  
  paste("t(",df,") = ",z, ", p-value = ",p, " ",sig,sep="")
}

tTestResults <- data.frame()
tTestResultsAdj <- data.frame()
tTestResultsCorrected <- data.frame()

for(k in 1:length(vars)) {
  row <- 1
  for(i in 1:(length(treatments)-1)) {
    for(j in (i+1):length(treatments)) {
      if(treatments[i] != treatments[j]) {
        row <- row + 1
        treat1 <- treatments[i]
        treat2 <- treatments[j]
        var <- vars[k]
        tTestResults[row,1] <- paste(treat1, " - ", treat2, sep="")
        tTestResults[row,k+1] <- tTestResult(data,treat1,treat2,var)
        
        tTestResultsAdj[row,1] <- paste(treat1, " - ", treat2, sep="")
        tTestResultsAdj[row,k+1] <- tTestResult(dataAdj,treat1,treat2,var)
        
        tTestResultsCorrected[row,1] <- paste(treat1, " - ", treat2, sep="")
        tTestResultsCorrected[row,k+1] <- tTestResult(dataCorrected,treat1,treat2,var)
      }
    }
  }
}

tTestResults <- tTestResults[2:11,]
tTestResultsAdj <- tTestResultsAdj[2:11,]
tTestResultsCorrected <- tTestResultsCorrected[2:11,]


names(tTestResults) <- c("Untersuchung",vars)
names(tTestResultsAdj) <- c("Untersuchung",vars)
names(tTestResultsCorrected) <- c("Untersuchung",vars)

##########################
###### SPURWECHSEL #######
##########################

spurwechselRes <- data.frame()

spurwechselProbTreat <- aggregate(interactions$Section, by = list(interactions$Treatment, interactions$Proband), max)
names(spurwechselProbTreat) <- c("Treatment", "Proband", "LaneChanges")
# manually add Probadn 14 and 15 , counted in LCT Analyzer
#14 interactions = 12 lc
#15 interactions = 11 lc
spurwechselProbTreat <- rbind(spurwechselProbTreat, c("Interaction","14",12))
spurwechselProbTreat <- rbind(spurwechselProbTreat, c("Interaction","15",11))

spurwechselProbTreat$Treatment <- tolower(spurwechselProbTreat$Treatment)

spurwechselErrorsProbTreat <- aggregate(data$MissedOrWrong, by=list(data$Treatment, data$Proband), FUN=sum)
names(spurwechselErrorsProbTreat) <- c("Treatment", "Proband", "Errors") 
spurwechselErrorsProbTreat <- spurwechselErrorsProbTreat[spurwechselErrorsProbTreat$Treatment!="base",]

spur <- merge(spurwechselProbTreat,spurwechselErrorsProbTreat)
spur$LaneChanges <- as.numeric(spur$LaneChanges)
spur$Errors <- as.numeric(spur$Errors)

spur$relative <- spur$Errors/spur$LaneChanges

####################################
# Unterschiede in den Spurwechseln #
####################################

spurWilcoxResults <- data.frame()

spurTreat <- c("user", "drive", "interaction", "track")

row <- 0
for(i in 1:(length(spurTreat)-1)) {
    for(j in (i+1):length(spurTreat)) {
      if(spurTreat[i] != spurTreat[j]) {
        row <- row + 1
        treat1 <- spurTreat[i]
        treat2 <- spurTreat[j]
        spurWilcoxResults[row,1] <- paste(treat1, " - ", treat2, sep="")
        spurWilcoxResults[row,2] <- wilcoxResult(spur,treat1,treat2,"relative")
      }
    }
}



########

spurwechselData <- aggregate(data$Missed, by=list(Category=data$Treatment), FUN=sum)
spurwechselData$Wrong <- aggregate(data$Wrong, by=list(Category=data$Treatment), FUN=sum)

#Anzahl Spurwechsel -> Number of Sections
spurwechselRes <- aggregate(interactions$Section, by = list(interactions$Treatment, interactions$Proband), max)
names(spurwechselRes) <- c("Treatment", "Proband", "LaneChanges") 
spurwechselRes <- aggregate(spurwechselRes$LaneChanges, by = list(spurwechselRes$Treatment), sum)




spurwechselRes[1,3] <-  6
spurwechselRes[2,3] <-  3
spurwechselRes[3,3] <-  0
spurwechselRes[4,3] <-  2
names(spurwechselRes) <- c("Treatment","Gesamt","Fehlerhaft")


spurwechselResult <- data.frame()

for(k in 1:length(vars)) {
  row <- 1
  for(i in 1:(length(treatments)-1)) {
    for(j in (i+1):length(treatments)) {
      if(treatments[i] != treatments[j]) {
        row <- row + 1
        treat1 <- treatments[i]
        treat2 <- treatments[j]
        print(paste(treat1," . " ,treat2))
        var <- vars[k]
        
        spurwechselResult[row,1] <- paste(treat1, " - ", treat2, sep="")
        spurwechselResult[row,k+1] <- wilcoxResult(data, treat1,treat2,var)
        
        }
    }
  }
}

wilResult <- wilResult[2:11,]


##########################
######### GRAPHS #########
##########################

boxplot(data$Mdev ~ data$Treatment, ylab="MDev", xlab="Treatment", main="MDev Boxplot", names=c("Baseline", "Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))
boxplot(dataAdj$Mdev ~ dataAdj$Treatment, ylab="MDev", xlab="Treatment", main="MDev Boxplot - Adjusted Data", names=c("Baseline", "Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))
boxplot(dataCorrected$Mdev ~ dataCorrected$Treatment, ylab="MDev", 
        xlab="Treatment", main="MDev Boxplot - Corrected Data", 
        names=c("Baseline", "Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))

boxplot(data$SDdev ~ data$Treatment, ylab="SDDev", xlab="Treatment", main="SDDev Boxplot", names=c("Baseline", "Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))
boxplot(dataAdj$SDdev ~ dataAdj$Treatment, ylab="SDDev", xlab="Treatment", main="SDDev Boxplot - Adjusted Data", names=c("Baseline", "Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))

mean_base <- mean(data$Mdev[data$Treatment=="base"])
mean_drive <- mean(data$Mdev[data$Treatment=="drive"])
mean_track <- mean(data$Mdev[data$Treatment=="track"])
mean_inter <- mean(data$Mdev[data$Treatment=="interaction"])
mean_user <- mean(data$Mdev[data$Treatment=="user"])

sd_base <- sd(data$Mdev[data$Treatment=="base"])
sd_drive <- sd(data$Mdev[data$Treatment=="drive"])
sd_track <- sd(data$Mdev[data$Treatment=="track"])
sd_inter <- sd(data$Mdev[data$Treatment=="interaction"])
sd_user <- sd(data$Mdev[data$Treatment=="user"])

mean_baseAdj <- mean(dataAdj$Mdev[dataAdj$Treatment=="base"])
mean_driveAdj <- mean(dataAdj$Mdev[dataAdj$Treatment=="drive"])
mean_trackAdj <- mean(dataAdj$Mdev[dataAdj$Treatment=="track"])
mean_interAdj <- mean(dataAdj$Mdev[dataAdj$Treatment=="interaction"])
mean_userAdj <- mean(dataAdj$Mdev[dataAdj$Treatment=="user"])

sd_baseAdj <- sd(dataAdj$Mdev[dataAdj$Treatment=="base"])
sd_driveAdj <- sd(dataAdj$Mdev[dataAdj$Treatment=="drive"])
sd_trackAdj <- sd(dataAdj$Mdev[dataAdj$Treatment=="track"])
sd_interAdj <- sd(dataAdj$Mdev[dataAdj$Treatment=="interaction"])
sd_userAdj <- sd(dataAdj$Mdev[dataAdj$Treatment=="user"])

mean_baseCorrected <- mean(dataCorrected$Mdev[dataCorrected$Treatment=="base"])
mean_driveCorrected <- mean(dataCorrected$Mdev[dataCorrected$Treatment=="drive"])
mean_trackCorrected <- mean(dataCorrected$Mdev[dataCorrected$Treatment=="track"])
mean_interCorrected <- mean(dataCorrected$Mdev[dataCorrected$Treatment=="interaction"])
mean_userCorrected <- mean(dataCorrected$Mdev[dataCorrected$Treatment=="user"])

sd_baseCorrected <- sd(dataCorrected$Mdev[dataCorrected$Treatment=="base"])
sd_driveCorrected <- sd(dataCorrected$Mdev[dataCorrected$Treatment=="drive"])
sd_trackCorrected <- sd(dataCorrected$Mdev[dataCorrected$Treatment=="track"])
sd_interCorrected <- sd(dataCorrected$Mdev[dataCorrected$Treatment=="interaction"])
sd_userCorrected <- sd(dataCorrected$Mdev[dataCorrected$Treatment=="user"])

means <- c(mean_base,mean_drive,mean_inter,mean_track,mean_user)
sds <- c(sd_base, sd_drive, sd_inter,sd_track, sd_user)
treatmentsLabel2 <- c("Baseline","Fahrtb.","Streckenb.","Eingabeb.", "Benutzerb.")
treatmentsLabel <- c("Baseline","Fahrtb.","Eingabeb.","Streckenb.", "Benutzerb.")

meansAdj <- c(mean_baseAdj,mean_driveAdj,mean_trackAdj,mean_interAdj,mean_userAdj)
sdsAdj <- c(sd_baseAdj, sd_driveAdj, sd_trackAdj, sd_interAdj, sd_userAdj)

meansCorrected <- c(mean_baseCorrected,mean_driveCorrected,mean_interCorrected,mean_trackCorrected,mean_userCorrected)
sdsCorrected <- c(sd_baseCorrected, sd_driveCorrected,sd_interCorrected, sd_trackCorrected, sd_userCorrected)

df <- data.frame(means,sds,treatmentsLabel)
dfAdj <- data.frame(meansAdj,sdsAdj,treatmentsLabel)
dfCorrected <- data.frame(meansCorrected,sdsCorrected,treatmentsLabel)

ggplot(df, aes(x = factor(treatmentsLabel, level = treatmentsLabel),y = means, group = 1)) +
  geom_point(size=3, shape=4) + 
  geom_line() +
  geom_errorbar(aes(ymin = means-sds, ymax = means+sds), width = 0.3) +
  xlab("Treatments") + ylab("MDev") + ggtitle("MDev Performance") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

ggplot(dfAdj, aes(x = factor(treatmentsLabel, level = treatmentsLabel),y = meansAdj, group = 1)) +
  geom_point(size=3, shape=4) + 
  geom_line() +
  geom_errorbar(aes(ymin = meansAdj-sdsAdj, ymax = meansAdj+sdsAdj), width = 0.3) +
  xlab("Treatments") + ylab("MDev") + ggtitle("MDev Performance - Adj. Data") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

ggplot(dfCorrected, aes(x = factor(treatmentsLabel, level = treatmentsLabel),y = meansCorrected, group = 1)) +
  geom_point(size=3, shape=4) + 
  geom_line() +
  geom_errorbar(aes(ymin = meansCorrected-sdsCorrected, ymax = meansCorrected+sdsCorrected), width = 0.3) +
  xlab("Treatments") + ylab("MDev") + ggtitle("MDev Performance - Corr. Data") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))
