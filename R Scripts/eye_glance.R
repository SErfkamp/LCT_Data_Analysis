
## PREPARING DATA - BUILD UP EYE TRACKING DATA ##

os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/Eye_Tracking/Corrected/output/error_corrected/categorized/",sep = ""), pattern="*.txt", full.names=T, recursive=FALSE)

### READ CORRECTION FILE ###
CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")

corr <- read.table(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file

result <- data.frame()
for(i in 1:length(files)) {

  t <- read.table(files[i], header=T, stringsAsFactors = FALSE) # load file
  
  proband <- strsplit(files[i],"/")[[1]][13]
  proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
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

  straightDist = sum(t$Straight_Section[grepl("Tablet",t$AOI)])
  lcStartDist = sum(t$LC_Start[grepl("Tablet",t$AOI)])
  lcDuringDist = sum(t$LC_During[grepl("Tablet",t$AOI)])
  lcEndDist = sum(t$LC_end[grepl("Tablet",t$AOI)])
  
  totalDist = straightDist + lcStartDist + lcDuringDist + lcEndDist
  
  glanceStraight = straightDist/totalDist * totalGlance
  glanceLCStart = lcStartDist/totalDist * totalGlance
  glanceLCDuring = lcDuringDist/totalDist * totalGlance
  glanceLCEnd = lcEndDist/totalDist * totalGlance
   
  glanceStraightPercentage = straightDist/totalDist
  glanceLCStartPercentage = lcStartDist/totalDist
  glanceLCDuringPercentage = lcDuringDist/totalDist
  glanceLCEndPercentage = lcEndDist/totalDist
  
  
  glanceOver500 = sum(grepl("Tablet",t$AOI) & t$Duration >= 500 & t$Duration < 1000)
  glanceOver1000 = sum(grepl("Tablet",t$AOI) & t$Duration >= 1000 & t$Duration < 1500)
  glanceOver1500 = sum(grepl("Tablet",t$AOI) & t$Duration >= 1500 & t$Duration < 2000)
  glanceOver1600 = sum(grepl("Tablet",t$AOI) & t$Duration >= 1600)
  glanceOver2000 = sum(grepl("Tablet",t$AOI) & t$Duration >= 2000 & t$Duration < 2500)
  glanceOver2500 = sum(grepl("Tablet",t$AOI) & t$Duration >= 2500 & t$Duration < 3000)
  glanceOver3000 = sum(grepl("Tablet",t$AOI) & t$Duration >= 3000)
  
  result_row <- data.frame(proband,
                           totalGlance,avgGlance,numGlances,maxGlance,
                           glanceStraight, glanceLCStart, glanceLCDuring, glanceLCEnd,
                           glanceStraightPercentage, glanceLCStartPercentage, glanceLCDuringPercentage, glanceLCEndPercentage,
                           glanceOver500,glanceOver1000,glanceOver1500, glanceOver1600,glanceOver2000, glanceOver2500,glanceOver3000)
  
  names(result_row) <- c("Proband", 
                         "TotalGlance", "AvgGlance","NumGlances", "MaxGlance",
                         "glanceStraight", "glanceLCStart", "glanceLCDuring", "glanceLCEnd",
                         "glanceStraightPercentage", "glanceLCStartPercentage", "glanceLCDuringPercentage", "glanceLCEndPercentage",
                         "dur_500","dur_1000","dur_1500","dur_1600","dur_2000","dur_2500","dur_3000")
  result <- rbind(result, result_row)
}

## END ##


## APPEND PERFORMANCE DATA - WITH PREFORMATTED DATA ##
diff <- read.csv(sep = ";",paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/results_iso.csv",sep = ""), header=T, stringsAsFactors = FALSE) # load file
diff_Straight_LC <- read.csv(sep = ";",paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/results_iso_straight_lc.csv",sep=""), header=T, stringsAsFactors = FALSE) # load file


diff$Diff <- as.numeric(gsub(",",".",diff$Diff))
diff$MDev <- as.numeric(gsub(",",".",diff$MDev))
diff$SDDev <- as.numeric(gsub(",",".",diff$SDDev))
diff$MDevSteeringAngle <- abs(as.numeric(gsub(",",".",diff$MDevSteeringAngle)))
diff$DiffSteering <-abs(as.numeric(gsub(",",".",diff$DiffSteering)))
diff$SDSteering <-abs(as.numeric(gsub(",",".",diff$SDSteering)))
diff$Base <- diff$MDev - diff$Diff
diff$Relative <- diff$MDev / diff$Base
diff <- subset(diff, select = -c(File,Ref))
result <- merge(result,diff,by.x = "Proband", by.y = "Participant")

diff_Straight_LC$DiffStraight <- as.numeric(gsub(",",".",diff_Straight_LC$DiffStraight))
diff_Straight_LC$MDevStraight <- as.numeric(gsub(",",".",diff_Straight_LC$MDevStraight))
diff_Straight_LC$SDDevStraight <- as.numeric(gsub(",",".",diff_Straight_LC$SDDevStraight))
diff_Straight_LC$MDevSteeringAngleStraight <- abs(as.numeric(gsub(",",".",diff_Straight_LC$MDevSteeringStraight)))
diff_Straight_LC$DiffSteeringStraight <-abs(as.numeric(gsub(",",".",diff_Straight_LC$DiffSteeringStraight)))
diff_Straight_LC$BaseStraight <- diff_Straight_LC$MDevStraight - diff_Straight_LC$DiffStraight
diff_Straight_LC$RelativeStraight <- diff_Straight_LC$MDevStraight / diff_Straight_LC$BaseStraight

diff_Straight_LC$DiffLC <- as.numeric(gsub(",",".",diff_Straight_LC$DiffLC))
diff_Straight_LC$MDevLC <- as.numeric(gsub(",",".",diff_Straight_LC$MDevLC))
diff_Straight_LC$SDDevLC <- as.numeric(gsub(",",".",diff_Straight_LC$SDDevLC))
diff_Straight_LC$MDevSteeringAngleLC <- abs(as.numeric(gsub(",",".",diff_Straight_LC$MDevSteeringLC)))
diff_Straight_LC$DiffSteeringLC <-abs(as.numeric(gsub(",",".",diff_Straight_LC$DiffSteeringLC)))
diff_Straight_LC$BaseLC <- diff_Straight_LC$MDevLC - diff_Straight_LC$DiffLC
diff_Straight_LC$RelativeLC <- diff_Straight_LC$MDevLC / diff_Straight_LC$BaseLC

diff_Straight_LC <- subset(diff_Straight_LC, select = -c(File,Ref))

#names(diff_Straight_LC) <- c("File", "Proband", "Ref", "MDev", "MDevSteeringAngle", "Diff" ,"DiffSteering","Base", "Relative")
result <- merge(result,diff_Straight_LC,by.x = "Proband", by.y = "Participant")

result$Proband <- as.numeric(result$Proband)
result <- result[order(result$Proband),] 
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

ggscatter(result, x = "glanceStraight", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "glanceLCStart", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "glanceLCDuring", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "glanceLCEnd", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

ggscatter(result, x = "glanceStraightPercentage", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "glanceLCStartPercentage", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "glanceLCDuringPercentage", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")
ggscatter(result, x = "glanceLCEndPercentage", y = "Diff", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

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
ggscatter(result, x = "NumGlances", y = "TotalGlance", add = "reg.line", conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson")

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

