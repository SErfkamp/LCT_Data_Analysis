os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/Merged/",sep = ""), pattern="*.csv", full.names=T, recursive=FALSE)

CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")
corr <- read.csv(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file

outputPath <- paste(os, "OneDrive/Thesis/Auswertung/Data Analysis/Inputs/normalized.csv")

for(i in 1:length(files)) {
  
  inputs <- read.csv(files[i], header=T, stringsAsFactors = FALSE, sep = ";")
  if(ncol(inputs) == 1) {
    inputs <- read.csv(files[i], header=T, stringsAsFactors = FALSE, sep = ",")
  }
  
  proband <- strsplit(files[i],"/")[[1]][9]
  proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
  # adapative standard lc positionen
  offset <- corr$Offset[corr$Proband==proband]
  
  inputs <- 

  

}
