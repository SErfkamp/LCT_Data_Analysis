library(readxl)
library(ggplot2)
library(coin)
library(lme4)
library(lmerTest)
library(agricolae)


# Pfade
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

path <-  paste(os,"OneDrive/Thesis/Studie/Auswertung.xlsx",sep="")
data <- read_excel(path, sheet = "LCTAnalyzer_output")
data <- data[data$Valid==1,]

dataAdj <- data[!data$Proband %in% data$Proband[data$MissedOrWrong>0],]

treatments <- c("base","user", "drive", "interaction", "track")
vars <- c("Mdev", "SDdev")#, "MSteer", "SDSteer", "MSpeed")

# -------------------------------------------------------------
# Test for normality #
# -------------------------------------------------------------

normalityRes <- data.frame()

test <- shapiro.test(as.matrix(data[vars[i]]))
normalityRes[1,i] <- paste("W = ",round(test$statistic,4),", p-value = ", round(test$p.value,4), sep="")

##########################
# NON - PARAMETRIC TESTS #
##########################

# -------------------------------------------------------------
# Friedman #
# -------------------------------------------------------------

test <- friedman(data$Proband, data$Treatment, data$Mdev, console=T)
friedmanRes <- paste("Chi-Quadrat(",test$statistics$Df,") = ",round(test$statistics$F,4),", p-value = ", round(test$statistics$p.chisq,4), sep="")

# -------------------------------------------------------------
# Non-Parametric Correlations #
# -------------------------------------------------------------

wilcoxResult <- function (data, treat1, treat2, var) {
  
  tempData <- subset(data,Treatment==treat1 | Treatment==treat2)
  tempData$Treatment <- factor(tempData$Treatment)
  tempData$Proband <- factor(tempData$Proband)
  tempFormula <- as.formula(paste(var," ~ Treatment | Proband",sep=""))
  test <- wilcoxsign_test(tempFormula, tempData, console=T)
  
  z <- round(statistic(test),4)
  p <- round(pvalue(test),4)
  
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

for(k in 1:length(vars)) {
  row <- 1
  for(i in 1:(length(treatments)-1)) {
    for(j in (i+1):length(treatments)) {
      if(treatments[i] != treatments[j]) {
        row <- row + 1
        treat1 <- treatments[i]
        treat2 <- treatments[j]
        var <- vars[k]
        wilResult[row,1] <- paste(treat1, " - ", treat2, sep="")
        wilResult[row,k+1] <- wilcoxResult(data, treat1,treat2,var)
        wilResultAdj[row,1] <- paste(treat1, " - ", treat2, sep="")
        wilResultAdj[row,k+1] <- wilcoxResult(dataAdj, treat1,treat2,var)
      }
    }
  }
}

wilResult <- wilResult[2:11,]
wilResultAdj <- wilResultAdj[2:11,]

names(wilResult) <- c("Untersuchung",vars)
names(wilResultAdj) <- c("Untersuchung",vars)


##########################
#### PARAMETRIC TESTS ####
##########################

# -------------------------------------------------------------
# ANOVA #
# -------------------------------------------------------------

anovaRes <- data.frame()

rmaModel <- lmer(Mdev ~ Treatment + (1|Proband), data)
test <- anova(rmaModel)
anovaRes <- paste("F(",round(test$NumDF,0),",",round(test$DenDF,0),") = ",round(test$`F value`,4),", p-value = ", round(test$`Pr(>F)`,4), sep="")


# -------------------------------------------------------------
# Parametric Correlations #
# -------------------------------------------------------------

tTestResult <- function (data, treat1, treat2, var) {
  
  tempData <- subset(data,Treatment==treat1 | Treatment==treat2)
  tempFormula <- as.formula(paste("tempData$",var," ~ tempData$Treatment",sep=""))
  
  test <- t.test(tempFormula, paired = T)
  mean <- mean(tempData[var])
  sd <- 
  df <- round(test$parameter,0)
  z <- round(test$statistic,4)
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
  
  paste("t(",df,") = ",z, ", p-value = ",p, " ",sig,sep="")
}

tTestResults <- data.frame()
tTestResultsAdj <- data.frame()

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
      }
    }
  }
}

tTestResults <- tTestResults[2:11,]
tTestResultsAdj <- tTestResultsAdj[2:11,]

names(tTestResults) <- c("Untersuchung",vars)
names(tTestResultsAdj) <- c("Untersuchung",vars)

##########################
######### GRAPHS #########
##########################

boxplot(data$Mdev ~ data$Treatment, ylab="MDev", xlab="Treatment", main="MDev Boxplot")
boxplot(dataAdj$Mdev ~ dataAdj$Treatment, ylab="MDev", xlab="Treatment", main="MDev Boxplot - Adjusted Data")

boxplot(data$SDdev ~ data$Treatment, ylab="SDDev", xlab="Treatment", main="SDDev Boxplot")
boxplot(dataAdj$SDdev ~ dataAdj$Treatment, ylab="SDDev", xlab="Treatment", main="SDDev Boxplot - Adjusted Data")
