
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/LC_Sections/",sep = ""), pattern="*_wisch.txt", full.names=T, recursive=FALSE)
lc_file_path <- paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/lc_analysis/",sep = "")
output_path <- paste(os,"OneDrive/Thesis/Auswertung/Daten/Prior_LC_Penalty_Area/",sep = "")

CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")
corr <- read.csv(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file

for(i in 1:length(files)) {
  
  # initial lc section file
  inputs <- read.table(files[i], header=F, stringsAsFactors = FALSE, sep = "\t")
  names(inputs) <- c("lc_start", "lc_end")
  
  proband <- strsplit(files[i],"/")[[1]][9]
  proband <- as.numeric(strsplit(proband, "_")[[1]][1])
  
  adaptive_lc_start <- corr$LC_start[corr$Proband==proband]
  adaptive_lc_end <- corr$LC_end[corr$Proband==proband]
  
  # read real lc time
  path <- paste(lc_file_path, proband,".CSV",sep="")
  lc <- read.table(path, header=T, stringsAsFactors = FALSE, sep = ";")
  
  # alten Wert + adaptive_lc_start + ind_lc_start - 10/15
  
  inputs$lc_end <- inputs$lc_start + 5
  inputs$lc_start <- inputs$lc_start - 20
  
  write.table(inputs,paste(output_path, proband,".txt", sep=""),row.names = F, col.names = F,quote = F,sep = "\t")
}