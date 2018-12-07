# Lane Change Analysis

os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/LC_Sections/",sep = ""), pattern="*.txt", full.names=T, recursive=FALSE)

CORRECTION_FILE = paste(os,"OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv",sep="")

corr <- read.csv(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file

int[] tracks = {0, 3335, 6510, 9783, 12985, 16279, 19525, 22843, 26113, 29383};

# probanden iterieren

for(i in 1:length(files)) {
  
  proband <- strsplit(files[i],"/")[[1]][13]
  proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
# adapative standard lc positionen
  lc_end <- corr$LC_start[corr$Proband==proband]
  lc_start <- corr$LC_end[corr$Proband==proband]
  
# alte lc section lesen
  

# für jede alte lc section

# adaptive wert abziehen 
# dlap wert hinzurechnen 

#speichern 