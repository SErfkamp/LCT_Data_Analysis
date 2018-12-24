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
interactions <- read_excel(path, sheet = "Interactions")
inputs_while_locked <- interactions[interactions$Interaction == "input-while-locked",]
interactions <- interactions[interactions$Interaction != "input-while-locked",]

treatments <- c("User", "Drive", "Interaction", "Track")
vars <- c("TaskDuration", "LockingDuration", "SecondsPerInteractionUnlocked", "InteractionsWhileLocked")

##########################
######  TASK TIME  #######
##########################

inputs <- data.frame(rep(1:32,each=4), rep(treatments,1) ,rep(9999,128),rep(0,128),rep(0,128), rep(0,128), rep(0,128))
names(inputs) <- c("Proband", "Treatment", "first", "last","start_time","end_time","count_inputs")

for(j in 1:length(treatments)) {
  tempData <- interactions[interactions$Treatment==treatments[j],]
  treatment <- treatments[j]
  
  for(i in 1:nrow(tempData)) {
    proband <- tempData$Proband[i]
    xpos <- tempData$Xpos[i]
    zeit <- tempData$Zeit[i]
    
    inputs[inputs$Treatment==treatment & inputs$Proband==proband,7] <- inputs[inputs$Treatment==treatment & inputs$Proband==proband,7] + 1
    
    currentFirstXpos <- inputs$first[inputs$Treatment==treatment & inputs$Proband==proband]
    currentLastXpos <- inputs$last[inputs$Treatment==treatment & inputs$Proband==proband]
    
    if(xpos < currentFirstXpos) {
      inputs[inputs$Treatment==treatment & inputs$Proband==proband,3] <- xpos
      inputs[inputs$Treatment==treatment & inputs$Proband==proband,5] <- zeit
    }
    if(xpos > currentLastXpos) {
      inputs[inputs$Treatment==treatment & inputs$Proband==proband,4] <- xpos
      inputs[inputs$Treatment==treatment & inputs$Proband==proband,6] <- zeit
    }
    
  }
}

inputs$TaskDuration = (inputs$end_time - inputs$start_time) / 1000
inputs = inputs[inputs$TaskDuration>0,] # Did not record lockings / inputs for Proband 14 & 15 :(

grouped_data <- aggregate(inputs_while_locked, by=list(inputs_while_locked$Treatment, inputs_while_locked$Proband), FUN=length);
grouped_data <- subset(grouped_data, select=c("Group.1", "Group.2", "Task"))
names(grouped_data) <- c("Treatment", "Proband","InteractionsWhileLocked")

inputs <- merge(inputs, grouped_data, all = T)
inputs[is.na(inputs)] <- 0

##########################
#######  LOCKINGS  #######
##########################

lockings <- read_excel(path, sheet = "Lockings")
#lockings <- lockings[lockings$Proband!=1,]
lockings$LockingDuration <- (lockings$End - lockings$Start)/1000


lockingsRes <- data.frame("Proband"= character(1), "Treatment" = character(1), "Duration" = numeric(1), stringsAsFactors = F)

for(i in 1:length(treatments)) {
  treatment <- treatments[i]
  tempData <- lockings[lockings$Treatment==treatment,]

  for(j in 1:32) {
    tempTempData <- tempData[tempData$Proband==j,]
    row <- c(j, treatment, sum(tempTempData$LockingDuration))
    lockingsRes <- rbind(lockingsRes, row)
  }
}
lockingsRes <- lockingsRes[2:nrow(lockingsRes),]
names(lockingsRes) <- c("Proband", "Treatment", "LockingDuration")
lockingsRes$LockingDuration <- as.numeric(lockingsRes$LockingDuration)
lockingsRes$Treatment <- as.factor(lockingsRes$Treatment)
lockingsRes = lockingsRes[lockingsRes$LockingDuration>0 | lockingsRes$Treatment=="User",] # Did not record lockings / inputs for Proband 14 & 15 :(


res <- merge(inputs,lockingsRes)
res$UnlockedDuration <- as.numeric(res$TaskDuration) - as.numeric(res$LockingDuration)
res$SecondsPerInteractionUnlocked <- res$UnlockedDuration / res$count_inputs
res$SecondsPerInteractionLocked <- res$TaskDuration / res$count_inputs



##########################
######### GRAPHS #########
##########################

# Total Task Duration
boxplot(res$TaskDuration ~ res$Treatment, ylab="Task Duration", xlab="Treatment", main="Task Duration")

# Locking Duration
boxplot(res$LockingDuration ~ res$Treatment, ylab="Locking Duration", xlab="Treatment", main="Locking Duration")

# Time between Interactions - Unlocked Duration
boxplot(res$SecondsPerInteractionUnlocked ~ res$Treatment, ylab="Duration", xlab="Treatment", main="Time between Interactions - Unlocked Duration")

# Inputs while locked
boxplot(res$Task ~ res$Treatment, ylab="Inputs while locked", xlab="Treatment", main="Inputs while locked")

### Filtering out proband 14 & 15
temp <- res[res$Proband!=14 & res$Proband!=15,] 
###

# -------------------------------------------------------------
# General #
# -------------------------------------------------------------

generalRes <- data.frame()
for(i in 1:length(treatments)) {
  treatment <- treatments[i]
  treatTemp <- subset(temp,Treatment==treatment)
  row <- i
  
  for(j in 1:length(vars)) {
    test <- describe(as.matrix(treatTemp[vars[j]]))
    generalRes[row,j] <- paste("M = ",round(test$mean,2),", SD = ", round(test$sd,2), sep="")
  }
}


# -------------------------------------------------------------
# Test for normality #
# -------------------------------------------------------------

normalityRes <- data.frame()

for(i in 1:length(vars)) {
  test <- shapiro.test(as.matrix(temp[vars[i]]))
  normalityRes[1,i] <- paste("W = ",round(test$statistic,4),", p-value = ", round(test$p.value,4), sep="")
}

# -------------------------------------------------------------
# Friedman #
# -------------------------------------------------------------

friedmanRes <- data.frame()

for(i in 1:length(vars)) {
  test <- friedman(temp$Proband,temp$Treatment, as.matrix(temp[vars[i]]))
  friedmanRes[1,i] <- paste("F = ",round(test$statistics$F,4),", p-value = ", round(test$statistics$p.chisq,4), sep="")
}

# -------------------------------------------------------------
# Correlations #
# -------------------------------------------------------------

wilcoxResult <- function (data, treat1, treat2, var) {
  
  tempData <- subset(data,Treatment==treat1 | Treatment==treat2)
  tempData$Treatment <- factor(tempData$Treatment)
  tempData$Proband <- factor(tempData$Proband)
  tempFormula <- as.formula(paste(var," ~ Treatment | Proband",sep=""))
  wil <- wilcoxsign_test(tempFormula, tempData, console=T)
  
  z <- round(statistic(wil),4)
  p <- round(pvalue(wil),4)
  
  #if(p>1) p<-2-p
  
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

result <- data.frame()
for(k in 1:length(vars)) {
  row <- 1
  for(i in 1:(length(treatments)-1)) {
    for(j in (i+1):length(treatments)) {
      if(treatments[i] != treatments[j]) {
        row <- row + 1
        treat1 <- treatments[i]
        treat2 <- treatments[j]
        var <- vars[k]
        result[row,1] <- paste(treat1, " - ", treat2, sep="")
        result[row,k+1] <- wilcoxResult(temp,treat1,treat2,var)
        #print(paste(treat1, " - ", treat2, " - ", var ,": ", wilcoxResult(treat1,treat2,var),sep=""))
      }
    }
  }
}
result <- result[2:7,]
names(result) <- c("Untersuchung",vars)

