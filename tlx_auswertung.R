library(readxl)

#os <- "C:/Users/serfk/"
os <- "/Users/se/"

# RStudio

path <- paste(os,"OneDrive/Thesis/Studie/Auswertung.xlsx",sep="")
data <- read_excel(path, sheet = "DALI")

tlxFactor = c("Mental Demand",
              "Physical Demand",
              "Temporal Demand",
              "Own Performance",
              "Effort",
              "Frustration")

tlxFactorShort = c("MD",
                   "PD",
                   "TD",
                   "OP",
                   "EF",
                   "FR")

# tlx factors are already ordered
tlxFactor = factor(tlxFactor, levels = tlxFactor)
tlxFactorShort = factor(tlxFactorShort, levels = tlxFactorShort)

#ggplot

#https://github.com/nicoversity/tlx-vis-r

#wilcox.test(data$mdev_treat_task, data$mdev_treat_notask, alternative = "g", paired=TRUE, conf.level=0.95)

