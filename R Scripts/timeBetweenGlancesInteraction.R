os <- "C:/Users/serfk/"
#os <- "/Users/se/"

files <- list.files(path=paste(os,"OneDrive/Thesis/Auswertung/Daten/Merged/",sep = ""), pattern="*.csv", full.names=T, recursive=FALSE)

n <- 0
sum <- 0
min <- 99999
minProband <- 0
minEnd <- 0
j<-0
openGlance <- F
previousInputTime <- 0
previousEvent <- ""
handOffWheel = 

allValues <- c()

for(i in 1:length(files)) {
  
  inputs <- read.csv(files[i], header=T, stringsAsFactors = FALSE, sep = ";")
  if(ncol(inputs) == 1) {
    inputs <- read.csv(files[i], header=T, stringsAsFactors = FALSE, sep = ",")
  }
  
  proband <- strsplit(files[i],"/")[[1]][9]
  proband <- as.numeric(strsplit(proband, "\\.")[[1]][1])
  
  for (row in 1:nrow(inputs)) {
    
    if(inputs[row,"Event"] == "Hand leaves steering wheel") {
      handOffWheel = T
      previousEvent = "Hand leaves steering wheel"
      next
    }
    
    if(inputs[row,"Event"] == "Hand returns to steering wheel") {
      handOffWheel = F
      previousEvent = "Hand returns to steering wheel"
      next
    }
    
    if(inputs[row,"Event"] == "Start") {
      previousEvent = "Start"
      openGlance <- F
      previousInputTime <- 0
      next
    }
    
    if(inputs[row,"Event"] == "glance_start") {
      previousEvent = "glance_start"
      openGlance = T
      next
    }
    
    if(inputs[row,"Event"] == "glance_end") {
      previousEvent = "glance_end"
      openGlance = F
      next
    }
    
    if(inputs[row,"Event"] == "Input") {
      
      if(is.nan(inputs[row,"Milliseconds"]) || is.na(inputs[row,"Milliseconds"])) {
        next
      }
      
      if(!openGlance) next
      
      if(previousInputTime == 0) {
        previousInputTime <- inputs[row,"Milliseconds"]
        previousEvent = "Input"
        next
      }
      
      if(previousEvent == "Hand leaves steering wheel") {
        next
      }
      
      if(!handOffWheel) {
        next
      }
      
      if(previousEvent == "glance_start") {
        timeBetweenInputs = inputs[row,"Milliseconds"] - previousInputTime
        
        #Proband 23 uncertainty
        if(timeBetweenInputs == 440) next

        if(timeBetweenInputs < 3000) {
          allValues <- c(allValues, timeBetweenInputs)
        }
        previousInputTime <- inputs[row,"Milliseconds"]
        
        sum <- sum + timeBetweenInputs
        n <- n+1
        
        if(timeBetweenInputs < min) {
          min <- timeBetweenInputs
          minProband <- proband
          minEnd <- previousInputTime
        }
        
        print(paste("Proband", proband, "tBInputs", timeBetweenInputs))
      
      }
      
      previousEvent = "Input"
      previousInputTime <- inputs[row,"Milliseconds"]
      #print(paste("Proband", proband, "tBInputs", timeBetweenInputs, "sum", sum, "n", n))
    }
  }
}

average = sum / n

qts <- quantile(allValues,probs=.10)
hist(allValues, main = "Time between Inputs with glance on street inbetween")


abline(v=qts[1],col="red")