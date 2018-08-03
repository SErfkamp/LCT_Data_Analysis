
## PREPARING DATA - BUILD UP EYE TRACKING DATA ##

#files <- list.files(path="C:/Users/serfk/Documents/Thesis/Daten/Eye_Tracking/Corrected/output/error_corrected/", pattern="*.txt", full.names=T, recursive=FALSE)
files <- list.files(path="C:/Users/serfk/Documents/Thesis/Daten/Eye_Tracking/Corrected/output/error_corrected/categorized/", pattern="*.txt", full.names=T, recursive=FALSE)

### READ CORRECTION FILE ###
CORRECTION_FILE = "C:/Users/serfk/Documents/Thesis/Data Analysis/correction_values.csv"
corr <- read.table(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file

result <- data.frame()
for(i in 1:length(files)) {

  t <- read.table(files[i], header=T, stringsAsFactors = FALSE) # load file
  
  proband <- strsplit(files[i],"/")[[1]][12]
  proband <- strsplit(proband, "\\.")[[1]][1]
  
  #filter out glances where proband didnt interact
  if(!is.na(corr$start_1[corr$Proband==proband])) {
    
    start_1 <- corr$start_1[corr$Proband==proband]
    end_1 <- corr$end_1[corr$Proband==proband]
    start_2 <- corr$start_2[corr$Proband==proband]
    end_2 <- corr$end_2[corr$Proband==proband]
    start_3 <- corr$start_3[corr$Proband==proband]
    end_3 <- corr$end_3[corr$Proband==proband]
    
    t <- t[t$Start_Time > start_1 & t$End_Time < end_1 
           |t$Start_Time > start_2 & t$End_Time < end_2 
           |t$Start_Time > start_3 & t$End_Time < end_3,]
  }
  
  totalGlance = sum(t$Duration[grepl("Tablet",t$AOI)])
  avgGlance = mean(t$Duration[grepl("Tablet",t$AOI)])
  numGlances = sum(grepl("Tablet",t$AOI))
  maxGlance = max(t$Duration[grepl("Tablet",t$AOI)],na.rm = TRUE)
  
  totalGlanceStraight = sum(t$Duration[grepl("Tablet",t$AOI) & t$Straight_Section==1])
  avgGlanceStraight = mean(t$Duration[grepl("Tablet",t$AOI) & t$Straight_Section==1])
  numGlancesStraight = sum(grepl("Tablet",t$AOI) & t$Straight_Section==1)
  maxGlanceStraight = max(t$Duration[grepl("Tablet",t$AOI) & t$Straight_Section==1],na.rm = TRUE)
  
  totalGlanceLC = sum(t$Duration[grepl("Tablet",t$AOI) & t$Straight_Section==0])
  avgGlanceLC = mean(t$Duration[grepl("Tablet",t$AOI) & t$Straight_Section==0])
  numGlancesLC = sum(grepl("Tablet",t$AOI) & t$Straight_Section==0)
  maxGlanceLC = max(t$Duration[grepl("Tablet",t$AOI) & t$Straight_Section==0],na.rm = TRUE)
  
  glanceOver500 = sum(grepl("Tablet",t$AOI) & t$Duration >= 500 & t$Duration < 1000)
  glanceOver1000 = sum(grepl("Tablet",t$AOI) & t$Duration >= 1000 & t$Duration < 1500)
  glanceOver1500 = sum(grepl("Tablet",t$AOI) & t$Duration >= 1500 & t$Duration < 2000)
  glanceOver1600 = sum(grepl("Tablet",t$AOI) & t$Duration >= 1600)
  glanceOver2000 = sum(grepl("Tablet",t$AOI) & t$Duration >= 2000 & t$Duration < 2500)
  glanceOver2500 = sum(grepl("Tablet",t$AOI) & t$Duration >= 2500 & t$Duration < 3000)
  glanceOver3000 = sum(grepl("Tablet",t$AOI) & t$Duration >= 3000)
  
  result_row <- data.frame(proband,
                           totalGlance,avgGlance,numGlances,maxGlance,
                           totalGlanceStraight,avgGlanceStraight,numGlancesStraight,maxGlanceStraight,
                           totalGlanceLC,avgGlanceLC,numGlancesLC,maxGlanceLC,
                           glanceOver500,glanceOver1000,glanceOver1500, glanceOver1600,glanceOver2000, glanceOver2500,glanceOver3000)
  
  names(result_row) <- c("Proband", 
                         "TotalGlance", "AvgGlance","NumGlances", "MaxGlance",
                         "TotalGlanceStraight", "AvgGlanceStraight","NumGlancesStraight", "MaxGlanceStraight",
                         "TotalGlanceLC", "AvgGlanceLC","NumGlancesLC", "MaxGlanceLC",
                         "dur_500","dur_1000","dur_1500","dur_1600","dur_2000","dur_2500","dur_3000")
  result <- rbind(result, result_row)
}

## END ##


## APPEND PERFORMANCE DATA - WITH PREFORMATTED DATA ##
#diff <- read.csv(sep = ";","C:/Users/serfk/Documents/Thesis/Data Analysis/results_simple.csv", header=T, stringsAsFactors = FALSE) # load file
#diff <- read.csv(sep = ";","C:/Users/serfk/Documents/Thesis/Data Analysis/results_iso.csv", header=T, stringsAsFactors = FALSE) # load file
diff <- read.csv(sep = ";","C:/Users/serfk/Documents/Thesis/Data Analysis/results_dlpa.csv", header=T, stringsAsFactors = FALSE) # load file


diff$Diff <- as.numeric(gsub(",",".",diff$Diff))
diff$MDev <- as.numeric(gsub(",",".",diff$MDev))
diff$MDevSteeringAngle <- abs(as.numeric(gsub(",",".",diff$MDevSteeringAngle)))
diff$DiffSteering <-abs(as.numeric(gsub(",",".",diff$DiffSteering)))
diff$Base <- diff$MDev - diff$Diff
diff$Relative <- diff$MDev / diff$Base
names(diff) <- c("File", "Proband", "Ref", "MDev", "MDevSteeringAngle", "Diff" ,"DiffSteering","Base", "Relative")
result <- merge(result,diff[,c("Proband","MDev","Diff", "MDevSteeringAngle", "DiffSteering","Base","Relative")],by.x = "Proband", by.y = "Proband")
result <- result[result$TotalGlance > 0,]

## END ##

boxplot(diff$Diff, diff$MDev, result$TotalGlance/50000)
boxplot(result$TotalGlance, result$TotalGlanceStraight, result$TotalGlanceLC)
boxplot(result$AvgGlance, result$AvgGlanceStraight, result$AvgGlanceLC)
boxplot(result$MaxGlance, result$MaxGlanceStraight, result$MaxGlanceLC)
boxplot(result$NumGlances, result$NumGlancesStraight, result$NumGlancesLC)


## CORRELATION TESTS ##

library(ggpubr)
ggscatter(result, x = "TotalGlance", y = "Diff",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlance", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "NumGlances", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "MaxGlance", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "TotalGlance", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "NumGlances", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlance", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "MaxGlance", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "TotalGlanceStraight", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "NumGlancesStraight", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlanceStraight", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "MaxGlanceStraight", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "TotalGlance", y = "Relative",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlance", y = "Relative", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "NumGlances", y = "Relative", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "MaxGlance", y = "Relative", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "TotalGlance", y = "DiffSteering",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlance", y = "DiffSteering", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "NumGlances", y = "DiffSteering", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "MaxGlance", y = "DiffSteering", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "TotalGlance", y = "MDevSteeringAngle",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlance", y = "MDevSteeringAngle", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "NumGlances", y = "MDevSteeringAngle", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "MaxGlance", y = "MDevSteeringAngle", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "AvgGlance", y = "NumGlances", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlance", y = "TotalGlance", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "AvgGlance", y = "MaxGlance", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "Diff", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "dur_500", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1000", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1500", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1600", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_2000", y = "MDev", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "dur_500", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1000", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1500", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1600", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_2000", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "dur_500", y = "Relative",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1500", y = "Relative",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_1600", y = "Relative",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_2000", y = "Relative",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "dur_2500", y = "Relative",  add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "MDev", y = "MDevSteeringAngle", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "Diff", y = "MDevSteeringAngle", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "MDev", y = "DiffSteering", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "Diff", y = "DiffSteering", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")


lm <- lm(Diff ~ TotalGlance + AvgGlance, data = result)
summary(lm)

pairs(result[,c("TotalGlance", "AvgGlance","NumGlances", "MaxGlance","dur_500","dur_1000","dur_1500","Diff")])

## END ##

