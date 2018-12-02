os <- "C:/Users/serfk/"
path <- "C:/Users/serfk/OneDrive/Thesis/Auswertung/Daten/Eye_tracking/Corrected/output/error_corrected/"

files <- list.files(path, pattern=".txt", full.names=T, recursive=FALSE)

CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")

corr <- read.table(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file

data <- data.frame()

for(i in 1:length(files)) {
  
  glances <- read.table(files[i], header=T, stringsAsFactors = FALSE, sep = "\t")
  
  proband <- strsplit(files[i],"/")[[1]][12]
  proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
  glances$proband <- proband
  
  start_1 <- corr$start_1[corr$Proband==proband]
  end_1 <- corr$end_1[corr$Proband==proband]
  start_2 <- corr$start_2[corr$Proband==proband]
  end_2 <- corr$end_2[corr$Proband==proband]
  start_3 <- corr$start_3[corr$Proband==proband]
  end_3 <- corr$end_3[corr$Proband==proband]
  
  glances <- glances[glances$Start_Time > start_1 & glances$End_Time < end_1 
         |glances$Start_Time > start_2 & glances$End_Time < end_2 
         |glances$Start_Time > start_3 & glances$End_Time < end_3,]

  
  data <- rbind(data, glances)
  
}

write.table(data, file = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/glances.csv",sep=""),sep = ";", row.names = FALSE)
