# -------------------------------------------------------------
# Data Preparation #
# -------------------------------------------------------------

library(readxl)
library(ggplot2)
library(agricolae)
library(coin)


# Pfade
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

path <-  paste(os,"OneDrive/Thesis/Studie/Auswertung.xlsx",sep="")
data <- read_excel(path, sheet = "DALI")

treatments <- c("User", "Drive", "Interaction", "Track")
vars <- c("effort_of_attention", "visual_demand", "auditory_demand", "temporal_demand", "interference", "situational_stress", "global")

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
    generalRes[row,j] <- paste("M = ",round(test$mean,2),", SD = ", round(test$sd,2), sep="")
  }
}

# -------------------------------------------------------------
# Test for normality #
# -------------------------------------------------------------

normalityRes <- data.frame()

for(i in 1:length(vars)) {
  test <- shapiro.test(as.matrix(data[vars[i]]))
  normalityRes[1,i] <- paste("W = ",round(test$statistic,4),", p-value = ", round(test$p.value,4), sep="")
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

#effort_of_attention
var1 <- mean(data$effort_of_attention[data$Treatment=="User"])
var2 <- mean(data$effort_of_attention[data$Treatment=="Interaction"])
var3 <- mean(data$effort_of_attention[data$Treatment=="Drive"])
var4 <- mean(data$effort_of_attention[data$Treatment=="Track"])
sd1 <- sd(data$effort_of_attention[data$Treatment=="User"])
sd2 <- sd(data$effort_of_attention[data$Treatment=="Interaction"])
sd3 <- sd(data$effort_of_attention[data$Treatment=="Drive"])
sd4 <- sd(data$effort_of_attention[data$Treatment=="Track"])

#visual_demand
var5 <- mean(data$visual_demand[data$Treatment=="User"])
var6 <- mean(data$visual_demand[data$Treatment=="Interaction"])
var7 <- mean(data$visual_demand[data$Treatment=="Drive"])
var8 <- mean(data$visual_demand[data$Treatment=="Track"])
sd5 <- sd(data$visual_demand[data$Treatment=="User"])
sd6 <- sd(data$visual_demand[data$Treatment=="Interaction"])
sd7 <- sd(data$visual_demand[data$Treatment=="Drive"])
sd8 <- sd(data$visual_demand[data$Treatment=="Track"])

#auditory_demand
var9 <- mean(data$auditory_demand[data$Treatment=="User"])
var10 <- mean(data$auditory_demand[data$Treatment=="Interaction"])
var11 <- mean(data$auditory_demand[data$Treatment=="Drive"])
var12 <- mean(data$auditory_demand[data$Treatment=="Track"])
sd9 <- sd(data$auditory_demand[data$Treatment=="User"])
sd10 <- sd(data$auditory_demand[data$Treatment=="Interaction"])
sd11 <- sd(data$auditory_demand[data$Treatment=="Drive"])
sd12 <- sd(data$auditory_demand[data$Treatment=="Track"])

#temporal_demand
var13 <- mean(data$temporal_demand[data$Treatment=="User"])
var14 <- mean(data$temporal_demand[data$Treatment=="Interaction"])
var15 <- mean(data$temporal_demand[data$Treatment=="Drive"])
var16 <- mean(data$temporal_demand[data$Treatment=="Track"])
sd13 <- sd(data$temporal_demand[data$Treatment=="User"])
sd14 <- sd(data$temporal_demand[data$Treatment=="Interaction"])
sd15 <- sd(data$temporal_demand[data$Treatment=="Drive"])
sd16 <- sd(data$temporal_demand[data$Treatment=="Track"])

#interference
var17 <- mean(data$interference[data$Treatment=="User"])
var18 <- mean(data$interference[data$Treatment=="Interaction"])
var19 <- mean(data$interference[data$Treatment=="Drive"])
var20 <- mean(data$interference[data$Treatment=="Track"])
sd17 <- sd(data$interference[data$Treatment=="User"])
sd18 <- sd(data$interference[data$Treatment=="Interaction"])
sd19 <- sd(data$interference[data$Treatment=="Drive"])
sd20 <- sd(data$interference[data$Treatment=="Track"])

#situational_stress
var21 <- mean(data$situational_stress[data$Treatment=="User"])
var22 <- mean(data$situational_stress[data$Treatment=="Interaction"])
var23 <- mean(data$situational_stress[data$Treatment=="Drive"])
var24 <- mean(data$situational_stress[data$Treatment=="Track"])
sd21 <- sd(data$situational_stress[data$Treatment=="User"])
sd22 <- sd(data$situational_stress[data$Treatment=="Interaction"])
sd23 <- sd(data$situational_stress[data$Treatment=="Drive"])
sd24 <- sd(data$situational_stress[data$Treatment=="Track"])

#global score
user <- mean(data$global[data$Treatment=="User"])
interaction <- mean(data$global[data$Treatment=="Interaction"])
drive <- mean(data$global[data$Treatment=="Drive"])
track <- mean(data$global[data$Treatment=="Track"])

usersd <- sd(data$global[data$Treatment=="User"])
interactionsd <- sd(data$global[data$Treatment=="Interaction"])
drivesd <- sd(data$global[data$Treatment=="Drive"])
tracksd <- sd(data$global[data$Treatment=="Track"])


attention = c(var1,var2,var3,var4)
visual = c(var5,var6,var7,var8)
auditory = c(var9,var10,var11,var12)
temporal = c(var13,var14,var15,var16)
interference = c(var17,var18,var19,var20)
stress = c(var21,var22,var23,var24)
global = c(user,interaction,drive,track)
alle = c(attention, visual, auditory, temporal, interference, stress, global)
treatment = c("User","Interaction", "Drive","Track")
scales = c("Effort of Attention","Visual Demand", "Auditory Demand","Temporal Demand", "Interference", "Situational Stress", "Global")
sdup = c(var1+sd1,var2+sd2,var3+sd3,var4+sd4,var5+sd5,var6+sd6,var7+sd7,var8+sd8,var9+sd9,var10+sd10,var11+sd11,var12+sd12,var13+sd13,var14+sd14,var15+sd15,var16+sd16,var17+sd17,var18+sd18,var19+sd19,var20+sd20,var21+sd21,var22+sd22,var23+sd23,var24+sd24,user+usersd,interaction+interactionsd,drive+drivesd,track+tracksd)
sddown=c(var1-sd1,var2-sd2,var3-sd3,var4-sd4,var5-sd5,var6-sd6,var7-sd7,var8-sd8,var9-sd9,var10-sd10,var11-sd11,var12-sd12,var13-sd13,var14-sd14,var15-sd15,var16-sd16,var17-sd17,var18-sd18,var19-sd19,var20-sd20,var21-sd21,var22-sd22,var23-sd23,var24-sd24,user-usersd,interaction-interactionsd,drive-drivesd,track-tracksd)


df <- data.frame(
  #x-Achse; immer so viele Balken, wie es gibt
  trt = factor(c("Effort of Attention","Effort of Attention","Effort of Attention","Effort of Attention","Visual Demand","Visual Demand","Visual Demand","Visual Demand","Auditory Demand","Auditory Demand","Auditory Demand","Auditory Demand","Temporal Demand","Temporal Demand","Temporal Demand","Temporal Demand","Interference","Interference","Interference","Interference","Situational Stress","Situational Stress","Situational Stress","Situational Stress","Global","Global","Global","Global")),
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
  ylim(-0.0, 20) +
  ggtitle("DALI Auswertung") +
  xlab("Faktoren") +
  ylab("Werte")

