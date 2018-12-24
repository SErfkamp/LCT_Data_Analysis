library(readxl)
library(ggplot2)
library(tidyr)
library(agricolae)
library(coin)

# Pfade
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

path <-  paste(os,"OneDrive/Thesis/Studie/Auswertung.xlsx",sep="")
data <- read_excel(path, sheet = "Ranking")

treatments <- c("User", "Drive", "Interaction", "Track")
vars <- c("bestes", "sicherstes", "userfriendly")

# -------------------------------------------------------------
# General #
# -------------------------------------------------------------

generalRes <- data.frame()

for(i in 1:length(treatments)) {
  treatment <- treatments[i]
  treatTemp <- subset(data,Treatment==treatment)
  row <- i
  
  for(j in 1:length(vars)) {
    test <- describe(as.matrix(treatTemp[vars[j]]))
    generalRes[row,j] <- paste("Mdn = ",round(test$median,2), sep="")
  }
}

# -------------------------------------------------------------
# Friedman #
# -------------------------------------------------------------

friedmanRes <- data.frame()

for(i in 1:length(vars)) {
  test <- friedman(data$Proband,data$Treatment, as.matrix(data[vars[i]]))
  friedmanRes[1,i] <- paste("F = ",round(test$statistics$F,4),", p-value = ", round(test$statistics$p.chisq,4), sep="")
}

# -------------------------------------------------------------
# Friedman Graphs #
# -------------------------------------------------------------

allgemein <- friedman(data$Proband,data$Treatment,data$bestes, console = T)
sicher <- friedman(data$Proband,data$Treatment,data$sicherstes, console = T)
benutzerfreundlich <- friedman(data$Proband,data$Treatment,data$userfriendly, console = T)

## TABLE: PAIRWISE WILCOXON ##
out<-with(data, allgemein)
plot(out, col = c("black","black","black","black"),main ="Bestes System: Gruppen und Interquartilsränge", ylab="Rang", xlab="Treatment", variation="IQR")

out<-with(data, sicher)
plot(out, col = c("black","black","black","black"),main ="Sicherstes System: Gruppen und Interquartilsränge", ylab="Rang", xlab="Treatment" , variation="IQR")

out<-with(data, benutzerfreundlich)
plot(out, col = c("black","black","black","black"),main ="Benutzerfreundlichstes System: Gruppen und Interquartilsränge", ylab="Rang", xlab="Treatment", variation="IQR")

# -------------------------------------------------------------
# Correlations #
# -------------------------------------------------------------

wilcoxResult <- function (treat1, treat2, var) {
  
  tempData <- subset(data,Treatment==treat1 | Treatment==treat2)
  tempData$Treatment <- factor(tempData$Treatment)
  tempData$Proband <- factor(tempData$Proband)
  tempFormula <- as.formula(paste(var," ~ Treatment | Proband",sep=""))
  wil <- wilcoxsign_test(tempFormula, tempData, console=T)
  
  z <- round(statistic(wil),4)
  p <- round(pvalue(wil),4)
  
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
        result[row,k+1] <- wilcoxResult(treat1,treat2,var)
        #print(paste(treat1, " - ", treat2, " - ", var ,": ", wilcoxResult(treat1,treat2,var),sep=""))
      }
    }
  }
}
result <- result[2:7,]
names(result) <- c("Untersuchung",vars)


# -------------------------------------------------------------
# Graph #
# -------------------------------------------------------------

#bestes
var1 <- mean(data$bestes[data$Treatment=="User"])
var2 <- mean(data$bestes[data$Treatment=="Interaction"])
var3 <- mean(data$bestes[data$Treatment=="Drive"])
var4 <- mean(data$bestes[data$Treatment=="Track"])
sd1 <- sd(data$bestes[data$Treatment=="User"])
sd2 <- sd(data$bestes[data$Treatment=="Interaction"])
sd3 <- sd(data$bestes[data$Treatment=="Drive"])
sd4 <- sd(data$bestes[data$Treatment=="Track"])


#sicherstes
var5 <- mean(data$sicherstes[data$Treatment=="User"])
var6 <- mean(data$sicherstes[data$Treatment=="Interaction"])
var7 <- mean(data$sicherstes[data$Treatment=="Drive"])
var8 <- mean(data$sicherstes[data$Treatment=="Track"])
sd5 <- sd(data$sicherstes[data$Treatment=="User"])
sd6 <- sd(data$sicherstes[data$Treatment=="Interaction"])
sd7 <- sd(data$sicherstes[data$Treatment=="Drive"])
sd8 <- sd(data$sicherstes[data$Treatment=="Track"])

#userfriendly
var9 <- mean(data$userfriendly[data$Treatment=="User"])
var10 <- mean(data$userfriendly[data$Treatment=="Interaction"])
var11 <- mean(data$userfriendly[data$Treatment=="Drive"])
var12 <- mean(data$userfriendly[data$Treatment=="Track"])
sd9 <- sd(data$userfriendly[data$Treatment=="User"])
sd10 <- sd(data$userfriendly[data$Treatment=="Interaction"])
sd11 <- sd(data$userfriendly[data$Treatment=="Drive"])
sd12 <- sd(data$userfriendly[data$Treatment=="Track"])

gesamt = c(var1,var2,var3,var4)
sicher = c(var5,var6,var7,var8)
userfriendly = c(var9,var10,var11,var12)

alle = c(gesamt, sicher, userfriendly)
treatment = c("User","Interaction", "Drive","Track")
scales = c("Gesamt","Sicherstes", "Einfachste Bedienung")
sdup = c(var1+sd1,var2+sd2,var3+sd3,var4+sd4,var5+sd5,var6+sd6,var7+sd7,var8+sd8,var9+sd9,var10+sd10,var11+sd11,var12+sd12)
sddown=c(var1-sd1,var2-sd2,var3-sd3,var4-sd4,var5-sd5,var6-sd6,var7-sd7,var8-sd8,var9-sd9,var10-sd10,var11-sd11,var12-sd12)

df <- data.frame(
  #x-Achse; immer so viele Balken, wie es gibt
  trt = factor(c("Gesamt","Gesamt","Gesamt","Gesamt","Sicherstes","Sicherstes","Sicherstes","Sicherstes","Einfachste Bedienung","Einfachste Bedienung","Einfachste Bedienung","Einfachste Bedienung")),
  #Mittelwert einfügen
  resp = c(alle),
  Treatment = treatment,
  scales = scales
)

p <- ggplot(df, aes(trt, resp, fill=Treatment))
p +
  geom_col(position = "dodge2") +
  geom_errorbar(
    aes(ymin = sddown, ymax = sdup),
    position = position_dodge2(width = 0.5, padding = 0.5)
  ) + 
  scale_fill_grey() + 
  theme_bw() + 
  scale_x_discrete(limits=scales) +
  ylim(-0.0, 4.15) +
  ggtitle("Ranking Auswertung") +
  xlab("") +
  ylab("Rang")