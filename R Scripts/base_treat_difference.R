### CONSTS ###
PATH = "C:/Users/serfk/Documents/Thesis/Data Analysis/base_wisch_marker_only.csv" 
#PATH = "C:/Users/serfk/Documents/Thesis/Data Analysis/base_wisch_marker_only_ADVANCED.csv" 


### READ FILE & PREPARE DATA ###
data <- read.table(PATH, sep=";", header=T, stringsAsFactors = FALSE) # load file
data <- subset(data, select=-c(Ref))
data$MDev <- as.numeric(gsub(",",".",data$MDev))
data$MDevSteeringAngle <- abs(as.numeric(gsub(",",".",data$MDevSteeringAngle)))
names(data) <- c("Run", "Proband", "MDev", "MDevSteeringAngle")
data$Run <- sapply(strsplit(data$Run, "_"), "[", 2)

### END DATA PREPARATION ###


### Normalverteilung der Differenzen ### 
diff <- data.frame(data$MDev[data$Run=="wisch"]) - data.frame(data$MDev[data$Run=="base"]) 
names(diff) <- c("Diff")
hist(diff$Diff)
library("ggpubr")
ggdensity(diff$Diff)
ggqqplot(diff$Diff)
shapiro.test(diff$Diff)
### END Normalverteilung Check

var(data$MDev[data$Run=="base"])
var(data$MDev[data$Run=="wisch"])


### t-Test / Wilcoxon ###
t.test(data$MDev[data$Run=="base"], data$MDev[data$Run=="wisch"], alternative = "l", paired=TRUE, conf.level=0.95)
wilcox.test(data$MDev[data$Run=="base"], data$MDev[data$Run=="wisch"], alternative = "l", paired=TRUE)

wilcox.test(data$MDevSteeringAngle[data$Run=="base"], data$MDevSteeringAngle[data$Run=="wisch"], alternative = "l", paired=TRUE)

### Plot of Data changes ###
library(PairedData)
base <- subset(data, Run=="base", MDev, drop = TRUE)
treat <- subset(data, Run=="wisch", MDev, drop = TRUE)
pd <- paired(base,treat)
plot(pd, type ="profile") + theme_bw()

### Plot of Data changes ###
base <- subset(data, Run=="base", MDevSteeringAngle, drop = TRUE)
treat <- subset(data, Run=="wisch", MDevSteeringAngle, drop = TRUE)
pd <- paired(base,treat)
plot(pd, type ="profile") + theme_bw()
