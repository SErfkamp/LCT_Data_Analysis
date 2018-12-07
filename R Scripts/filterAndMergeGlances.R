
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/Eye_Tracking/Corrected/output/error_corrected/only_straight/",sep = ""), pattern="*.txt", full.names=T, recursive=FALSE)

output <- paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/glances.txt", sep="")

corr <- read.csv(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file

result <- data.frame()

for(i in 1:length(files)) {
  
  proband <- strsplit(files[i],"/")[[1]][13]
  proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
  data <- read.table(files[i], header=T, stringsAsFactors = FALSE, sep = "\t")
  data$Proband <- proband
  
  start_1 <- corr$start_1[corr$Proband==proband]
  end_1 <- corr$end_1[corr$Proband==proband]
  start_2 <- corr$start_2[corr$Proband==proband]
  end_2 <- corr$end_2[corr$Proband==proband]
  start_3 <- corr$start_3[corr$Proband==proband]
  end_3 <- corr$end_3[corr$Proband==proband]

  data <- data[data$Start_Time > start_1 & data$End_Time < end_1 
             |data$Start_Time > start_2 & data$End_Time < end_2 
             |data$Start_Time > start_3 & data$End_Time < end_3,]

  result <- rbind(result, data)
  
}

write.table(result, output, quote = F,row.names = F, sep=";")
