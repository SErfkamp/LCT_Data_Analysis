os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/Merged/",sep = ""), pattern="*.csv", full.names=T, recursive=FALSE)

n <- 0
sum <- 0
min <- 0
max <- 0
maxProband <- 0
maxStart <- 0
maxEnd <- 0
j<-0
openGlance <- F
previousInputTime <- 0

allValues <- c()

for(i in 1:length(files)) {

  inputs <- read.csv(files[i], header=T, stringsAsFactors = FALSE, sep = ";")
  if(ncol(inputs) == 1) {
    inputs <- read.csv(files[i], header=T, stringsAsFactors = FALSE, sep = ",")
  }
  
  proband <- strsplit(files[i],"/")[[1]][9]
  proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
  for (row in 1:nrow(inputs)) {

    if(inputs[row,"Event"] == "Start" 
       | inputs[row,"Event"] == "Hand leaves steering wheel" 
       | inputs[row,"Event"] == "Hand returns to steering wheel") {
      openGlance <- F
      previousInputTime <- 0
      next
    }
    
    if(inputs[row,"Event"] == "glance_start") {
      openGlance = T
      next
    }
    
    if(inputs[row,"Event"] == "glance_end") {
      openGlance = F
      previousInputTime <- 0
      next
    }
    
    if(inputs[row,"Event"] == "Input") {
      
      if(!openGlance) next
      
      if(is.nan(inputs[row,"Milliseconds"]) || is.na(inputs[row,"Milliseconds"])) {
        next
      }
      
      if(previousInputTime == 0) {
        previousInputTime <- inputs[row,"Milliseconds"]
        next
      }
      
      timeBetweenInputs = inputs[row,"Milliseconds"] - previousInputTime
      allValues <- c(allValues, timeBetweenInputs)
      previousInputTime <- inputs[row,"Milliseconds"]

      sum <- sum + timeBetweenInputs
      n <- n+1
      
      print(paste("Proband", proband, "tBInputs", timeBetweenInputs, "sum", sum, "n", n))
      
      if(timeBetweenInputs > max) {
        max <- timeBetweenInputs
        maxProband <- proband
        maxEnd <- previousInputTime
      }
    }
  }
}

average = sum / n

qts <- quantile(allValues,probs=.90)
hist(allValues,breaks=10, main = "Zeit zwischen Eingaben bei durchgängigem Blick auf das IVIS", xlab="Dauer in ms", ylab="Anzahl")

qts
abline(v=qts[1],col="red")
n
