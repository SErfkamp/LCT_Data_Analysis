os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/Eye_Tracking/Corrected/output/error_corrected/categorized/",sep = ""), pattern="*.txt", full.names=T, recursive=FALSE)

### READ CORRECTION FILE ###
CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")

input_files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/IVIS_Inputs/",sep = ""), pattern="*.csv", full.names=T, recursive=FALSE)

C:\Users\serfk\OneDrive\Thesis\Auswertung\Daten\IVIS_Inputs
corr <- read.csv(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file


for(i in 1:length(input_files)) {
  
  inputs <- read.csv(input_files[i], header=T, stringsAsFactors = FALSE, sep = ",")
  inputs$Milliseconds <- inputs$Milliseconds - (inputs$Milliseconds[inputs$Event=="Start"]-9080)
  
  proband <- i # strsplit(files[i],"/")[[1]][13]
  #proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
  glance_file <- paste(os,"OneDrive/Thesis/Auswertung/Daten/Eye_Tracking/Corrected/output/error_corrected/categorized/",proband,".txt",sep = "")
 
  t <- read.table(glance_file, header=T, stringsAsFactors = FALSE) # load file
    
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
  
  offset <- corr$Offset[corr$Proband==proband]
  
  for(j in 1:nrow(t)) {
    row <- t[j,]
    
    inputs[nrow(inputs) + 1,] = list("Swipe","3","","glance_start","",row$Start_Time - offset,"")
    inputs[nrow(inputs) + 1,] = list("Swipe","3","","glance_end","",row$End_Time - offset,"")
    
  }
  
  inputs <- inputs[order(inputs$Milliseconds),]
  
  write.csv(inputs, file = paste(os,"OneDrive/Thesis/Auswertung/Daten/Merged/",proband,".csv",sep=""), row.names = FALSE)
    
}
