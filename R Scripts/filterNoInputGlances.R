
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")

file <- paste(os,"OneDrive/Thesis/Auswertung/Daten/test.txt",sep = "")
input_path <- paste(os,"OneDrive/Thesis/Auswertung/Daten/IVIS_Inputs/normalized/",sep = "")


output <- paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/glances.csv", sep="")

corr <- read.csv(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file
result <- data.frame()

data <- read.table(file, header=T, stringsAsFactors = FALSE, sep = "\t")


for(i in 1:31) {
  
  proband <- i
  inputs <- read.table(paste(input_path, proband, ".csv", sep=""), sep=",", header = T, fill = T, row.names = NULL)
  if(ncol(inputs) == 1) {
    inputs <- read.table(paste(input_path, proband, ".csv", sep=""), sep=";", header = T, fill = T, row.names = NULL)
  }
  inputs = inputs[inputs$Event=="Input",]
  inputs = inputs[!is.na(inputs$Milliseconds),]
  
  temp <- data[data$Proband==proband,]
  temp$Inputs = 0

  glance_offset <- corr$Offset[corr$Proband==proband]
  temp$Start_Time = temp$Start_Time - glance_offset
  temp$End_Time = temp$End_Time - glance_offset
  
  for (j in 1:nrow(temp)) {
    start = temp[j, "Start_Time"]
    end = temp[j, "End_Time"]
    
    for (k in 1:nrow(inputs)) {
      
      input = inputs[k, "Milliseconds"]
      
      print(paste("Proband: ", i, " - J: ",j," - K:",k))
      
      
      if (input >= start & input < end) {
        temp[j, "Inputs"] = temp[j, "Inputs"] + 1
      }
    }
  }
  
  result <- rbind (result, temp)
}

write.csv(result,file = output)
