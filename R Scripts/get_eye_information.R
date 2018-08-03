

files <- list.files(path="C:/Users/serfk/Documents/Thesis/Daten/Eye_Tracking/Corrected/output/error_corrected/", pattern="*.txt", full.names=T, recursive=FALSE)

### READ CORRECTION FILE ###
CORRECTION_FILE = "C:/Users/serfk/Documents/Thesis/Data Analysis/correction_values.csv"
corr <- read.table(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file


result <- data.frame()
for(i in 1:length(files)) {
  
  t <- read.table(files[i], header=T, stringsAsFactors = FALSE) # load file
  
  proband <- strsplit(files[i],"/")[[1]][11]
  proband <- strsplit(proband, "\\.")[[1]][1]
  
  #filter out glances where proband didnt interact
  if(!is.na(corr$start_1[corr$ï..Proband==proband])) {
    start_1 <- corr$start_1[corr$ï..Proband==proband]
    end_1 <- corr$end_1[corr$ï..Proband==proband]
    start_2 <- corr$start_2[corr$ï..Proband==proband]
    end_2 <- corr$end_2[corr$ï..Proband==proband]
    start_3 <- corr$start_3[corr$ï..Proband==proband]
    end_3 <- corr$end_3[corr$ï..Proband==proband]
    
    t <- t[t$Start_Time > start_1 & t$End_Time < end_1 
           |t$Start_Time > start_2 & t$End_Time < end_2 
           |t$Start_Time > start_3 & t$End_Time < end_3,]
  }
  
  totalGlance1 = sum(t$Duration[grepl("Tablet",t$AOI) & t$Start_Time < 70000])
  totalGlance2 = sum(t$Duration[grepl("Tablet",t$AOI) & t$Start_Time > 70000 & t$End_Time < 110000])
  totalGlance3 = sum(t$Duration[grepl("Tablet",t$AOI) & t$Start_Time > 110000])
  
  sumTotal = totalGlance1 + totalGlance2 + totalGlance3
  
  numGlances1 = sum(grepl("Tablet",t$AOI) & t$Start_Time < 70000)
  numGlances2 = sum(grepl("Tablet",t$AOI) & t$Start_Time > 70000 & t$End_Time < 110000)
  numGlances3 = sum(grepl("Tablet",t$AOI) & t$Start_Time > 110000)
  
  sumGlances = numGlances1 + numGlances2 + numGlances3
  
  avgGlance = sumTotal/sumGlances
  
  result_row <- data.frame(proband, 
                           totalGlance1, totalGlance2, totalGlance3, sumTotal,
                           numGlances1, numGlances2, numGlances3, sumGlances, avgGlance)
  
  names(result_row) <- c("Proband", 
                         "TotalGlance1" , "TotalGlance2", "TotalGlance3", "sumTotal",
                         "NumGlances1", "NumGlances2", "NumGlances3", "sumGlances","avgGlance")
  
  result <- rbind(result, result_row)
}
