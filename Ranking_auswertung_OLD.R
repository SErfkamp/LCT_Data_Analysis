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

# Data Preparation
best <- data[,1:3]
best$Treatment <- as.factor(best$Treatment)
best$Proband <- as.factor(best$Proband)

safest <- data[,c(1,2,4)]
safest$Treatment <- as.factor(safest$Treatment)
safest$Proband <- as.factor(safest$Proband)

userfriendly <- data[,c(1,2,5)]
userfriendly$Treatment <- as.factor(userfriendly$Treatment)
userfriendly$Proband <- as.factor(userfriendly$Proband)


## FRIEDMANN ##
bestResult <- friedman(best$Proband,best$Treatment,best$bestes, console = T)
safestResult <- friedman(safest$Proband,safest$Treatment,safest$sicherstes, console = T)
userfriendlyResult <- friedman(userfriendly$Proband,userfriendly$Treatment,userfriendly$userfriendly, console = T)


## TABLE: PAIRWISE WILCOXON ##
out<-with(best, bestResult)
plot(out, col = c("black","black","black","black"),main ="Bestes System: Gruppen und Interquartilsränge", ylab="Rang", xlab="Treatment", variation="IQR")
pairwise.wilcox.test(best$bestes,best$Treatment, paired=T, correct=F, exact=F, p.adj="none")

out<-with(safest, safestResult)
plot(out, col = c("black","black","black","black"),main ="Sicherstes System: Gruppen und Interquartilsränge", ylab="Rang", xlab="Treatment" , variation="IQR")
pairwise.wilcox.test(safest$sicherstes,safest$Treatment, paired=T, correct=F, exact=F, p.adj="none", correct=F)

out<-with(userfriendly, userfriendlyResult)
plot(out, col = c("black","black","black","black"),main ="Benutzerfreundlichstes System: Gruppen und Interquartilsränge", ylab="Rang", xlab="Treatment", variation="IQR")
pairwise.wilcox.test(userfriendly$userfriendly,best$Treatment, paired=T, correct=F, exact=F, p.adj="none", correct=F)


## SINGLE: BEST WILCOXON ##
bestUserDrive <- subset(best,Treatment=="User" | Treatment=="Drive")
bestUserDrive$Treatment <- factor(bestUserDrive$Treatment)
bestUserInter <- subset(best,Treatment=="User" | Treatment=="Interaction")
bestUserInter$Treatment <- factor(bestUserInter$Treatment)
bestUserTrack <- subset(best,Treatment=="User" | Treatment=="Track")
bestUserTrack$Treatment <- factor(bestUserTrack$Treatment)
bestDriveInter <- subset(best,Treatment=="Drive" | Treatment=="Interaction")
bestDriveInter$Treatment <- factor(bestDriveInter$Treatment)
bestDriveTrack <- subset(best,Treatment=="Drive" | Treatment=="Track")
bestDriveTrack$Treatment <- factor(bestDriveTrack$Treatment)
bestInterTrack <- subset(best,Treatment=="Interaction" | Treatment=="Track")
bestInterTrack$Treatment <- factor(bestInterTrack$Treatment)

wilcoxsign_test(bestes~Treatment|Proband, bestUserDrive)
wilcoxsign_test(bestes~Treatment|Proband, bestUserInter)
wilcoxsign_test(bestes~Treatment|Proband, bestUserTrack)
wilcoxsign_test(bestes~Treatment|Proband, bestDriveInter)
wilcoxsign_test(bestes~Treatment|Proband, bestDriveTrack)
wilcoxsign_test(bestes~Treatment|Proband, bestInterTrack)

## SINGLE: SAFEST WILCOXON ##
safestUserDrive <- subset(safest,Treatment=="User" | Treatment=="Drive")
safestUserDrive$Treatment <- factor(safestUserDrive$Treatment)
safestUserInter <- subset(safest,Treatment=="User" | Treatment=="Interaction")
safestUserInter$Treatment <- factor(safestUserInter$Treatment)
safestUserTrack <- subset(safest,Treatment=="User" | Treatment=="Track")
safestUserTrack$Treatment <- factor(safestUserTrack$Treatment)
safestDriveInter <- subset(safest,Treatment=="Drive" | Treatment=="Interaction")
safestDriveInter$Treatment <- factor(safestDriveInter$Treatment)
safestDriveTrack <- subset(safest,Treatment=="Drive" | Treatment=="Track")
safestDriveTrack$Treatment <- factor(safestDriveTrack$Treatment)
safestInterTrack <- subset(safest,Treatment=="Interaction" | Treatment=="Track")
safestInterTrack$Treatment <- factor(safestInterTrack$Treatment)

wilcoxsign_test(sicherstes~Treatment|Proband, safestUserDrive)
wilcoxsign_test(sicherstes~Treatment|Proband, safestUserInter)
wilcoxsign_test(sicherstes~Treatment|Proband, safestUserTrack)
wilcoxsign_test(sicherstes~Treatment|Proband, safestDriveInter)
wilcoxsign_test(sicherstes~Treatment|Proband, safestDriveTrack)
wilcoxsign_test(sicherstes~Treatment|Proband, safestInterTrack)

## SINGLE: USER FRIENDLY WILCOXON ##
userfriendlyUserDrive <- subset(userfriendly,Treatment=="User" | Treatment=="Drive")
userfriendlyUserDrive$Treatment <- factor(userfriendlyUserDrive$Treatment)
userfriendlyUserInter <- subset(userfriendly,Treatment=="User" | Treatment=="Interaction")
userfriendlyUserInter$Treatment <- factor(userfriendlyUserInter$Treatment)
userfriendlyUserTrack <- subset(userfriendly,Treatment=="User" | Treatment=="Track")
userfriendlyUserTrack$Treatment <- factor(userfriendlyUserTrack$Treatment)
userfriendlyDriveInter <- subset(userfriendly,Treatment=="Drive" | Treatment=="Interaction")
userfriendlyDriveInter$Treatment <- factor(userfriendlyDriveInter$Treatment)
userfriendlyDriveTrack <- subset(userfriendly,Treatment=="Drive" | Treatment=="Track")
userfriendlyDriveTrack$Treatment <- factor(userfriendlyDriveTrack$Treatment)
userfriendlyInterTrack <- subset(userfriendly,Treatment=="Interaction" | Treatment=="Track")
userfriendlyInterTrack$Treatment <- factor(userfriendlyInterTrack$Treatment)

wilcoxsign_test(userfriendly~Treatment|Proband, userfriendlyUserDrive)
wilcoxsign_test(userfriendly~Treatment|Proband, userfriendlyUserInter)
wilcoxsign_test(userfriendly~Treatment|Proband, userfriendlyUserTrack)
wilcoxsign_test(userfriendly~Treatment|Proband, userfriendlyDriveInter)
wilcoxsign_test(userfriendly~Treatment|Proband, userfriendlyDriveTrack)
wilcoxsign_test(userfriendly~Treatment|Proband, userfriendlyInterTrack)


# -------------------------------------------------------------
# Correlations #
# -------------------------------------------------------------

#User - Drive	
wilcox.test(data$bestes[data$Treatment=="User"],data$bestes[data$Treatment=="Drive"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$sicherstes[data$Treatment=="User"],data$sicherstes[data$Treatment=="Drive"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$userfriendly[data$Treatment=="User"],data$userfriendly[data$Treatment=="Drive"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)

#User - Interaction	
wilcox.test(data$bestes[data$Treatment=="User"],data$bestes[data$Treatment=="Interaction"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$sicherstes[data$Treatment=="User"],data$sicherstes[data$Treatment=="Interaction"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$userfriendly[data$Treatment=="User"],data$userfriendly[data$Treatment=="Interaction"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)

#User - Track	
wilcox.test(data$bestes[data$Treatment=="User"],data$bestes[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$sicherstes[data$Treatment=="User"],data$sicherstes[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$userfriendly[data$Treatment=="User"],data$userfriendly[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)

#Drive - Interaction	
wilcox.test(data$bestes[data$Treatment=="Drive"],data$bestes[data$Treatment=="Interaction"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$sicherstes[data$Treatment=="Drive"],data$sicherstes[data$Treatment=="Interaction"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$userfriendly[data$Treatment=="Drive"],data$userfriendly[data$Treatment=="Interaction"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)

#Drive - Track	
wilcox.test(data$bestes[data$Treatment=="Drive"],data$bestes[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$sicherstes[data$Treatment=="Drive"],data$sicherstes[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$userfriendly[data$Treatment=="Drive"],data$userfriendly[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)

#Interaction - Track						
wilcox.test(data$bestes[data$Treatment=="Interaction"],data$bestes[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$sicherstes[data$Treatment=="Interaction"],data$sicherstes[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)
wilcox.test(data$userfriendly[data$Treatment=="Interaction"],data$userfriendly[data$Treatment=="Track"], paired = T, conf.int = T, conf.level = 0.95, mu=0, alt="two.sided", exact = F, correct = F)


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