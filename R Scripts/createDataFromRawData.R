library("xlsx")

# Pfade
os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Studie/Data/",sep = ""), include.dirs = T, full.names=T, recursive=FALSE)

excel <- paste(os,"OneDrive/Thesis/Studie/Auswertung.xlsx",sep="")

interactions <- data.frame()
lockings <- data.frame()

interactionsOutput <- paste(os, "OneDrive/Thesis/Studie/Daten/interactions.txt",sep="")
lockingsOutput <- paste(os, "OneDrive/Thesis/Studie/Daten/lockings.txt",sep="")

# Durch Ordner iterieren
for(i in 1:length(files)) {
  
  proband <- as.numeric(strsplit(files[i], "/")[[1]][8])

  # drivingTask Log öffnen und nach Proband schauen und Driver Name herausfinden
  runs <- list.files(files[i], include.dirs = T, full.names=T, recursive=FALSE)
  
  for(j in 1:length(runs)) {
    lock <- data.frame()
    inter <- data.frame()
    run <- runs[j]
    
    drivingLog <- read.table(paste(run,"/drivingTaskLog.txt",sep=""),sep=":", fill=T, stringsAsFactors = F)
    runName <- strsplit(drivingLog[1,2],split = "_")[[1]][2]
    probandCheck <- as.numeric(gsub(strsplit(drivingLog[1,2],split = "_")[[1]][1],pattern = " ", replacement = ""))
    
    if(proband != probandCheck) {
      print(paste("Error in proband ", proband, " - Proband Check: ", probandCheck))
    }
    
    if(runName != "base") {
      # interaction & locking file
      inter <- list.files(run, pattern = "_interactions.txt" , full.names=T)
      inter <- read.table(inter, sep=";", header = T)
      
      if(nrow(inter) > 0) {
        inter$Proband <- proband
        inter$Run <- runName
      }

      lock <- list.files(run, pattern = "_lockings.txt" , full.names=T)
      lock <- read.table(lock, sep=";", header = T)
      
      if(nrow(lock) > 0) {
        lock$Proband <- proband
        lock$Run <- runName
      }

      interactions <- rbind(interactions, inter)
      lockings <- rbind(lockings, lock)
    }
    
    driving <- list.files(run, pattern = "carData_track\\d\\.txt" , full.names=T)
    drivingPath <- paste(os, "OneDrive/Thesis/Studie/Daten/Driving/",proband,"_",runName,".txt",sep="")
    file.copy(from = driving,to = drivingPath, overwrite = T,recursive = F,copy.date = T)
    
  }
  
}

wb <- loadWorkbook(excel)
sheets <- getSheets(wb)
removeSheet(wb, sheetName="Interactions")
removeSheet(wb, sheetName="Lockings")

yourSheet <- createSheet(wb, sheetName="Interactions")
addDataFrame(interactions, yourSheet, row.names = F)

yourSheet <- createSheet(wb, sheetName="Lockings")
addDataFrame(lockings, yourSheet, row.names = F)
saveWorkbook(wb, file = excel)

write.table(interactions, interactionsOutput, quote = F, row.names = F, sep=";")
write.table(lockings, lockingsOutput, quote = F, row.names = F, sep=";")
