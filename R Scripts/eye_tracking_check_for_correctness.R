### CONSTS ###
#TOUCH
FOLDER = "C:/Users/serfk/OneDrive/Thesis/Auswertung/Daten/Eye_trackingtouch/CSVData/"
OUTPUT_FOLDER = "C:/Users/serfk/OneDrive/Thesis/Auswertung/Daten/Eye_trackingtouch/Corrected/"
CORRECTION_FILE = "C:/Users/serfk/OneDrive/Thesis/Auswertung/Data Analysis/correction_valuestouch.csv"

#SWIPE
#FOLDER = "C:/Users/serfk/OneDrive/Thesis/Auswertung/Daten/Eye_tracking/CSVData/"
#OUTPUT_FOLDER = "C:/Users/serfk/OneDrive/Thesis/Auswertung/Daten/Eye_tracking/Corrected/"
#CORRECTION_FILE = "C:/Users/serfk/OneDrive/Thesis/Auswertung/Data Analysis/correction_values.csv"


### READ CORRECTION FILE ###
corr <- read.table(CORRECTION_FILE, header=T, stringsAsFactors = FALSE, sep = ";") # load file
corr$slope <- sapply(corr$Values, function(x) as.numeric(strsplit(strsplit(x, " ")[[1]][3],"\n")[[1]][1]))
corr$y_distance <-sapply(corr$Values, function(x) as.numeric(strsplit(strsplit(x, " ")[[1]][5],"\n")[[1]][1]))
corr$v <- sapply(corr$Values, function(x) as.numeric(strsplit(strsplit(x, " ")[[1]][7],"\n")[[1]][1])) 
corr$h <- sapply(corr$Values, function(x) as.numeric(strsplit(strsplit(x, " ")[[1]][9],"\n")[[1]][1]))
corr$h2 <- sapply(corr$Values, function(x) as.numeric(strsplit(strsplit(x, " ")[[1]][11],"\n")[[1]][1]))
corr$orig_0 <- sapply(corr$Values, function(x) as.logical(strsplit(strsplit(x, " ")[[1]][13],"\n")[[1]][1]))
corr$orig_0[is.na(corr$orig_0)] <- FALSE
#corr <- corr[complete.cases(corr),]


### FOR LOOP CREATING FILES FOR ALL RUNS ###

# install.packages("svMisc")
require(svMisc)

result <- data.frame()
#pdf("C:/Users/serfk/OneDrive/Thesis/Auswertung/Data Analysis/glance_correction3.pdf")

### LOOP OVER RAW CSV GLANCE FILES ###
files <- list.files(path=FOLDER, pattern="*.txt", full.names=T, recursive=FALSE)
for(i in 1:length(files)) {
  progress(i,length(files), progress.bar = TRUE)
  
  
  # READ FILE AND PREPARE DATA #
  t <- read.table(files[i], header=T, stringsAsFactors = FALSE, sep = "\t") # load file
  proband <- strsplit(files[i],"_")[[1]][3]
  t <- subset(t, select = c("rec_time", "Dikablis.Professional_Field.Data_Scene.Cam_Original_Screen1", "Dikablis.Professional_Field.Data_Scene.Cam_Processed.20150915_111558.Data_Tablet1","Dikablis.Professional_Field.Data_Scene.Cam_Processed.20150915_111558.Data_Gaze_Gaze.X","Dikablis.Professional_Field.Data_Scene.Cam_Processed.20150915_111558.Data_Gaze_Gaze.Y"))
  names(t) <- c("rec_time", "Orig_Screen1", "Proc_Tablet1","X","Y")
  t <- t[complete.cases(t),]
  t <- t[t$X>0 & t$Y>0,]
  
  # INIT VARS #
  if (!(proband %in% corr$Proband)) next
  
  slope = as.numeric(corr$slope[corr$Proband == proband])
  y_distance = corr$y_distance[corr$Proband == proband]
  v = corr$v[corr$Proband == proband]
  h = corr$h[corr$Proband == proband]
  h2 = corr$h2[corr$Proband == proband]
  orig_0 = corr$orig_0[corr$Proband == proband]
  
  if(is.na(slope)) next
  
  # PLOT INITIAL #
  plot(t$X,t$Y,col=factor(1 + 2*t$Orig_Screen1 + t$Proc_Tablet1),main = paste("Proband", proband),xlim = c(0,3000), ylim = c(-400,1000))
  abline(a = y_distance, b = slope, col="blue")
  abline(v = v, col="blue")
  abline(h = h, col="blue")
  abline(h = h2, col="blue")
  legend("bottomleft", legend = c("IVIS", "Track", "Both", "None"), bty = "n",
         lwd = 2, cex = 1.2, col = c("red", "green" , "blue", "black"), lty = c(NA, NA, NA, NA), pch = c(1, 1, 1, 1))
  
  # ADD REC TIME IN MS #
  t$minutes <- as.numeric(sapply(strsplit(t$rec_time, ":"), "[", 2))*60000
  t$rec_time <- sapply(strsplit(t$rec_time, ":"), "[", 3)
  t$rec_time <- as.numeric(gsub("\\.","", t$rec_time))
  t$rec_time <- as.numeric(t$minutes + t$rec_time)
  
  # FILTER BY REC TIME #
  #t <- t[t$rec_time>20000 & t$rec_time<000 | t$rec_time>75000 & t$rec_time<110000 | t$rec_time>130000 & t$rec_time<170000, ]
  
  # CALC NEW VALUES #
  if (slope > 0) {
    t$newTablet <- ifelse((t$Proc_Tablet1==1 & !orig_0) | (t$X < v & t$Y < h2 & t$Y > h & (t$Y <= (t$X*slope+y_distance))),1,0)
  } else {
    t$newTablet <- ifelse((t$Proc_Tablet1==1 & !orig_0) | (t$X < v & t$Y < h2 & t$Y > h & (t$Y >= (t$X*slope+y_distance))),1,0)
  }
  
  # PLOT CORRECTION #
  plot(t$X,t$Y,col=factor(1 + 2*t$Orig_Screen1 + t$newTablet),main = paste("Proband", proband, "- Corrected"),xlim = c(0,3000), ylim = c(-400,1000))
  abline(a = y_distance, b = slope, col="blue")
  abline(v = v, col="blue")
  abline(h = h, col="blue")
  abline(h = h2, col="blue")
  legend("bottomleft", legend = c("IVIS", "Track", "Both", "None"), bty = "n",
         lwd = 2, cex = 1.2, col = c("red", "green" , "blue", "black"), lty = c(NA, NA, NA, NA), pch = c(1, 1, 1, 1))
  
  t<- subset(t, select =-c(minutes))
  
  # WRITE TO OUTPUT #
  write.table(format(t, trim=T, scientific = F), paste(OUTPUT_FOLDER,proband,".txt",sep=""), sep="\t", row.names = FALSE, quote = FALSE)
  
  if (i == length(files)) cat("Done!\n")
}

dev.off()

###




##### SAME FUNCTIONALITY BUT NO LOOP ####
# FOR TESTING PURPOSES TO SET THE CORRECT AREA #


SINGLE_FILE = FOLDER = "C:/Users/serfk/OneDrive/Thesis/Auswertung/Daten/Eye_tracking/CSVData/"
#SINGLE_FILE = FOLDER = "Z:/VP_8/"
FILE_NAME = "VP_23_2. Recording 26.08.2015 154525_CsvData"
FILE_NAME = paste(FILE_NAME,".txt", sep = "")
SINGLE_FILE = paste(SINGLE_FILE,FILE_NAME,sep="")


# READ FILE AND PREPARE DATA #
t <- read.table(SINGLE_FILE, header=T, stringsAsFactors = FALSE, sep = "\t") # load file
proband <- strsplit(SINGLE_FILE,"_")[[1]][3]
t <- subset(t, select = c("rec_time", "Dikablis.Professional_Field.Data_Scene.Cam_Original_Screen1", "Dikablis.Professional_Field.Data_Scene.Cam_Processed.20150915_111558.Data_Tablet1","Dikablis.Professional_Field.Data_Scene.Cam_Processed.20150915_111558.Data_Gaze_Gaze.X","Dikablis.Professional_Field.Data_Scene.Cam_Processed.20150915_111558.Data_Gaze_Gaze.Y"))
names(t) <- c("rec_time", "Orig_Screen1", "Proc_Tablet1","X","Y")
t <- t[complete.cases(t),]
t <- t[t$X>0 & t$Y>0,]

# INIT VARS #
if (!(proband %in% corr$ï..Proband)) next

'slope = corr$slope[corr$ï..Proband == proband]
y_distance = corr$y_distance[corr$ï..Proband == proband]
v = corr$v[corr$ï..Proband == proband]
h = corr$h[corr$ï..Proband == proband]
h2 = corr$h2[corr$ï..Proband == proband]
orig_0 = corr$orig_0[corr$ï..Proband == proband]'

slope = -1.5
y_distance = 2300
v = 1850
h = 450
h2 = 800
orig_0 = FALSE

#t <- t[t$Proc_Tablet1==1,]


# PLOT INITIAL #
plot(t$X,t$Y,col=factor(1 + 2*t$Orig_Screen1 + t$Proc_Tablet1),main = paste("Proband", proband),xlim = c(0,3000), ylim = c(-400,1000))
abline(a = y_distance, b = slope, col="blue")
abline(v = v, col="blue")
abline(h = h, col="blue")
abline(h = h2, col="blue")
legend("bottomleft", legend = c("IVIS", "Track", "Both", "None"), bty = "n",
       lwd = 2, cex = 1.2, col = c("red", "green" , "blue", "black"), lty = c(NA, NA, NA, NA), pch = c(1, 1, 1, 1))

# ADD REC TIME IN MS #
t$minutes <- as.numeric(sapply(strsplit(t$rec_time, ":"), "[", 2))*60000
t$rec_time <- sapply(strsplit(t$rec_time, ":"), "[", 3)
t$rec_time <- as.numeric(gsub("\\.","", t$rec_time))
t$rec_time <- as.numeric(t$minutes + t$rec_time)

# FILTER BY REC TIME #
t <- t[t$rec_time>22095 & t$rec_time<22200,] #| t$rec_time>75000 & t$rec_time<110000 | t$rec_time>130000 & t$rec_time<170000, ]
#t <- t[t$rec_time>31400 & t$rec_time<32150,] #| t$rec_time>75000 & t$rec_time<110000 | t$rec_time>130000 & t$rec_time<170000, ]


# CALC NEW VALUES #
if (slope > 0) {
  t$newTablet <- ifelse((t$Proc_Tablet1==1 & !orig_0) | (t$X < v & t$Y < h2 & t$Y > h & (t$Y <= (t$X*slope+y_distance))),1,0)
} else {
  t$newTablet <- ifelse((t$Proc_Tablet1==1 & !orig_0) | (t$X < v & t$Y < h2 & t$Y > h & (t$Y >= (t$X*slope+y_distance))),1,0)
}

#t <- t[t$newTablet==0,]

# PLOT CORRECTION #
plot(t$X,t$Y,col=factor(1 + 2*t$Orig_Screen1 + t$newTablet),main = paste("Proband", proband, "- Corrected"),xlim = c(0,3000), ylim = c(-400,1000))
abline(a = y_distance, b = slope, col="blue")
abline(v = v, col="blue")
abline(h = h, col="blue")
abline(h = h2, col="blue")
legend("bottomleft", legend = c("IVIS", "Track", "Both", "None"), bty = "n",
       lwd = 2, cex = 1.2, col = c("red", "green" , "blue", "black"), lty = c(NA, NA, NA, NA), pch = c(1, 1, 1, 1))
