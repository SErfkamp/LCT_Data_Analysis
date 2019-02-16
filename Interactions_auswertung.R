library(readxl)
library(ggplot2)
library(coin)
library(lme4)
library(lmerTest)
library(agricolae)
library(psych)
library(plm)


# Pfade
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

path <-  paste(os,"OneDrive/Thesis/Studie/Auswertung.xlsx",sep="")
interactions <- read_excel(path, sheet = "Interactions")

inputs_while_locked <- interactions[interactions$Interaction == "input-while-locked",]
interactions <- interactions[interactions$Interaction != "input-while-locked",]

treatments <- c("User", "Drive", "Interaction", "Track")
vars <- c("TaskDuration", "LockingDuration", "SecondsPerInteractionUnlocked", "InteractionsWhileLocked", "UnlockedDuration")

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

##########################
########  INPUTS  ########
##########################


track_locked_inputs_laneChange <- inputs_while_locked[(inputs_while_locked$DistanceToNextSign < 55 | inputs_while_locked$DistanceFromLastSign < 33.33) & inputs_while_locked$Run=="track",]
#195
track_locked_inputs_straight <- inputs_while_locked[inputs_while_locked$DistanceToNextSign > 55 & inputs_while_locked$DistanceFromLastSign > 33.33 & inputs_while_locked$Run=="track",]
#217

interaction_locked_inputs_laneChange <- inputs_while_locked[(inputs_while_locked$DistanceToNextSign < 40 | inputs_while_locked$DistanceFromLastSign < 10) & inputs_while_locked$Run=="interaction",]
#27
interaction_locked_inputs_straight <- inputs_while_locked[inputs_while_locked$DistanceToNextSign > 40 & inputs_while_locked$DistanceFromLastSign > 10 & inputs_while_locked$Run=="interaction",]
#81

drive_locked_inputs_laneChange <- inputs_while_locked[(inputs_while_locked$DistanceToNextSign < 40 | inputs_while_locked$DistanceFromLastSign < 10) & inputs_while_locked$Run=="drive",]
#30
drive_locked_inputs_straight <- inputs_while_locked[inputs_while_locked$DistanceToNextSign > 40 & inputs_while_locked$DistanceFromLastSign > 10 & inputs_while_locked$Run=="drive",]
#46

grouped_data <- aggregate(inputs_while_locked, by=list(inputs_while_locked$Treatment, inputs_while_locked$Proband), FUN=length);
grouped_data <- subset(grouped_data, select=c("Group.1", "Group.2", "Task"))
names(grouped_data) <- c("Treatment", "Proband","InteractionsWhileLocked")

inputs <- merge(inputs, grouped_data, all = T)
inputs[is.na(inputs)] <- 0

count_interactions <- aggregate(interactions, by=list(interactions$Treatment, interactions$Proband), FUN=length);
count_interactions <- subset(count_interactions, select=c("Group.1", "Group.2", "Task"))
names(count_interactions) <- c("Treatment", "Proband","InteractionsByProbandByTreatment")
count_interactions <- count_interactions[count_interactions$Proband != 14 & count_interactions$Proband != 15,]

# Inputs each Treatment
boxplot(count_interactions$InteractionsByProbandByTreatment ~ count_interactions$Treatment, ylab="Inputs while locked", xlab="Treatment", main="Inputs while locked")

means <- aggregate(count_interactions$InteractionsByProbandByTreatment, list(count_interactions$Treatment), mean)
names(means) <- c("Treatment", "Value")
sds <- aggregate(count_interactions$InteractionsByProbandByTreatment, list(count_interactions$Treatment), sd)
names(sds) <- c("Treatment", "Value")

df <- data.frame(means, sds,means$Treatment)

ggplot(df ,aes(x = df$Treatment,y = df$Value, ymin = 48, group = 1)) +
  geom_point(size=3, shape=4) + 
  geom_line() +
  theme_bw() +
  ylab("Durchsch. Interaktionen") +
  xlab("Treatments") +
  ggtitle("Durchschnittliche Interaktionen") +
  theme(plot.title = element_text(hjust = 0.5))

# -------------------------------------------------------------
# Correlations #
# -------------------------------------------------------------

wilcoxResultTask <- function (treat1, treat2) {
  tempData <- subset(count_interactions, Treatment==treat1 | Treatment==treat2)
  tempData$Proband <- factor(tempData$Proband)
  tempData$Treatment <- factor(tempData$Treatment)
  tempFormula <- as.formula(paste("InteractionsByProbandByTreatment"," ~ Treatment | Proband",sep=""))
  test <- wilcoxsign_test(tempFormula, tempData, console=T)

  z <- round(statistic(test),4)
  p <- round(pvalue(test),4)
  
  # 
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

taskResult <- data.frame()
row <- 0
for(i in 1:(length(treatments)-1)) {
  for(j in (i+1):length(treatments)) {
    if(treatments[i] != treatments[j]) {
      row <- row + 1
      treat1 <- treatments[i]
      treat2 <- treatments[j]
      taskResult[row,1] <- paste(treat1, " - ", treat2, sep="")
      taskResult[row,2] <- wilcoxResultTask(treat1,treat2)
    }
  }
}

##########################
#######  LOCKINGS  #######
##########################

lockings <- read_excel(path, sheet = "Lockings")
lockings <- lockings[lockings$Proband!=1,]
lockings <- lockings[lockings$Proband!=14,]
lockings <- lockings[lockings$Proband!=15,]
lockings$LockingDuration <- (lockings$End - lockings$Start)/1000

lockingCount <- data.frame(table(lockings$Proband,lockings$Treatment))
names(lockingCount) <- c("Proband","Treatment","Count")

lockDrive <- subset(lockingCount, Treatment=="Drive")
lockInteraction <- subset(lockingCount, Treatment=="Interaction")
lockTrack <- subset(lockingCount, Treatment=="Track")

summary(lockingCount[lockingCount$Treatment=="Drive",])
summary(lockingCount[lockingCount$Treatment=="Interaction",])
summary(lockingCount[lockingCount$Treatment=="Track",])

mean(lockDrive$Count)
mean(lockInteraction$Count)
mean(lockTrack$Count)

sd(lockDrive$Count)
sd(lockInteraction$Count)
sd(lockTrack$Count)




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
boxplot(res$TaskDuration ~ res$Treatment, ylab="Aufgabendauer in s", xlab="Treatment", main="Aufgabendauer", names=c("Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))

# Locking Duration
boxplot(res$LockingDuration ~ res$Treatment, ylab="Sperrdauer in s", xlab="Treatment", main="Sperrdauer", names=c("Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))

# Time between Interactions - Unlocked Duration
boxplot(res$SecondsPerInteractionUnlocked ~ res$Treatment, ylab="Dauer in s", xlab="Treatment", main="Zeit zwischen Interaktionen", names=c("Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))

# Inputs while locked
boxplot(res$InteractionsWhileLocked ~ res$Treatment, ylab="Inputs while locked", xlab="Treatment", main="Interaktionen bei gesperrtem IVIS", names=c("Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))

# Total Task Duration minus Locked Duration
boxplot(res$UnlockedDuration ~ res$Treatment, ylab="Unlocked Duration", xlab="Treatment", main="", names=c("Fahrtb.","Eingabenb.","Streckenb.","Benutzerb."))


res$UnlockedDuration

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

for(i in 1:length(treatments)) {
  
  treatment <- treatments[i]
  treatTemp <- subset(temp,Treatment==treatment)
  row <- i
  
  for (j in 1:length(vars)) {
    var <- vars[j]
    varData <- treatTemp[var]
    normalTempData <- as.matrix(varData)
    tryCatch({
      test <- shapiro.test(normalTempData)
      print(paste(treatment,var))
      
      normalityRes[row,j] <- paste("W = ",round(test$statistic,4),", p-value = ", round(test$p.value,4), sep="")
      print(paste("W = ",round(test$statistic,4),", p-value = ", round(test$p.value,4), sep=""))
      
    }, error=function(e){
      #normalityRes[row,j] <- "x"
    })
  }
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
# wilcox #
# -------------------------------------------------------------

wilcoxResult <- function (data, treat1, treat2, var) {
  
  tempData <- subset(data,Treatment==treat1 | Treatment==treat2)
  tempData$Treatment <- factor(tempData$Treatment)
  tempData$Proband <- factor(tempData$Proband)
  tempFormula <- as.formula(paste(var," ~ Treatment | Proband",sep=""))
  test <- wilcoxsign_test(tempFormula, tempData, console=T)
  
  z <- round(statistic(test),4)
  p <- round(pvalue(test),4)
  
  # 
  #Vorzeichen wird geändert nach Alphabetischer Reihenfolge der Treatments
  if (treat2 < treat1) {
    z <- z * -1
  }
  
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
        
        temp <- temp[temp$Proband!=1,]
        
        result[row,k+1] <- wilcoxResult(temp,treat1,treat2,var)
        #print(paste(treat1, " - ", treat2, " - ", var ,": ", wilcoxResult(treat1,treat2,var),sep=""))
      }
    }
  }
}
result <- result[2:7,]
names(result) <- c("Untersuchung",vars)

# -------------------------------------------------------------
# t-tests #
# -------------------------------------------------------------

tTestResult <- function (data, treat1, treat2, var) {
  
  tempData <- subset(data,Treatment==treat1 | Treatment==treat2)
  tempData$Treatment <- factor(tempData$Treatment)
  tempData$Proband <- factor(tempData$Proband)
  tempFormula <- as.formula(paste(var," ~ Treatment",sep=""))
  test <- t.test(tempFormula, tempData, console=T, paired = T)
  
 # y1 <- tempData$TaskDuration[tempData$Treatment==treat1]
 # y2 <- tempData$TaskDuration[tempData$Treatment==treat2]
  
  #tttest <- t.test(y1,y2, console=T, paired = T)
  
  z <- round(test$statistic,4)
  p <- round(test$p.value,4)
  
  # 
  #Vorzeichen wird geändert nach Alphabetischer Reihenfolge der Treatments
  if (treat2 < treat1) {
    z <- z * -1
  }
  
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

tTestRes <- data.frame()
for(k in 1:length(vars)) {
  row <- 1
  for(i in 1:(length(treatments)-1)) {
    for(j in (i+1):length(treatments)) {
      treat1 <- treatments[i]
      treat2 <- treatments[j]
      if(treat1 != treat2) {
        row <- row + 1

        var <- vars[k]
        tTestRes[row,1] <- paste(treat1, " - ", treat2, sep="")
        
        temp <- temp[temp$Proband!=1,]
        
        tTestRes[row,k+1] <- tTestResult(temp,treat1,treat2,var)
      }
    }
  }
}
tTestRes <- tTestRes[2:7,]
names(tTestRes) <- c("Untersuchung",vars)

