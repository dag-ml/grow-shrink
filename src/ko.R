# Author        - Jacob Campbell
# Project       - ML DAG: Grow-Shrink (Ko Data)
# Last Updated  - 7/30/23

library(dplyr)      # various helper functions
library(bnlearn)    # gs, some graph utilities
library(Rgraphviz)  # graph utilities
library(psych)      # pca

# When loading from local storage
data_dir <- "../data"

# Ko 2020 2 of 2
if(dir.exists(data_dir))  # Automatically load data
{
  # micro ct
  path_mct_lsds_40 <- file.path(data_dir, "LSDS-40_microCT_LSDS-40_microCT_KoTRANSFORMED.csv")
  data_mct_lsds_40 <- read.csv(path_mct_lsds_40, header=T)
  print("Loaded Ko - microCT from existing file")
  
  # histomorphometry
  path_hist_lsds_40 <- file.path(data_dir, "LSDS-40_histomorphometry_LSDS-40_histomorphometry_KoTRANSFORMED.csv")
  data_hist_lsds_40 <- read.csv(path_hist_lsds_40, header=T)
  print("Loaded Ko - histomorphometry from existing file")
  
  # bone
  path_bone_lsds_40 <- file.path(data_dir, "LSDS-40_Bone_Biomechanical_LDSD-40_biomechanical_KoTRANSFORMED.csv")
  data_bone_lsds_40 <- read.csv(path_bone_lsds_40, header=T)
  print("Loaded Ko - Bone Biomechanical from existing file")  
} else    # Manually load data
{
  # micro ct
  path_mct_lsds_40 <- file.choose()
  # histomorphometry
  path_hist_lsds_40 <- file.choose()
  # bone
  path_bone_lsds_40 <- file.choose()
  
  data_mct_lsds_40 <- read.csv(path_mct_lsds_40, header=T)
  data_hist_lsds_40 <- read.csv(path_hist_lsds_40, header=T)
  data_bone_lsds_40 <- read.csv(path_bone_lsds_40, header=T)
}

# Create valid subset
data_bone_lsds_40 <- data_bone_lsds_40[,c(1,3:4,8:10)]
data_hist_lsds_40 <- data_hist_lsds_40[!(is.na(data_hist_lsds_40$Source.Name)),c(1,7:11)]
data_mct_lsds_40 <- data_mct_lsds_40[,c(1,10,13:17)]

# Rename columns for convenience
names(data_bone_lsds_40) <- c("ID","PWB","duration","stiffness","load.max","load.fail")
names(data_hist_lsds_40) <- c("ID","OBSBS","OCSBS",'MSBS',"MAR","BFRBS")
names(data_mct_lsds_40) <- c("ID","BVTV","trab.num","trab.thick","trab.sep","BMD","cort.thick")

# Create src file index to confirm successful merge
data_bone_lsds_40$data_bone_lsds_40 <- 1
data_hist_lsds_40$data_hist_lsds_40 <- 1
data_mct_lsds_40$data_mct_lsds_40 <- 1

# Merge files
ko12   <- merge(data_bone_lsds_40,data_hist_lsds_40,by="ID",all.x=T,all.y=T)
ko123  <- merge(ko12,data_mct_lsds_40,by="ID",all=T)

ko123$data_bone_lsds_40[is.na(ko12$data_bone_lsds_40)] <-0
ko123$data_hist_lsds_40[is.na(ko12$data_hist_lsds_40)] <-0
ko123$data_mct_lsds_40[is.na(ko12$data_mct_lsds_40)] <-0

# Keep rows we need and remove NA entries
ko <-  ko123[!(is.na(ko123$stiffness)),]
ko$unload <- 0*(ko$PWB=='PWB100')+30*(ko$PWB=="PWB70")+60*(ko$PWB=="PWB40")+80*(ko$PWB =="PWB20")
ko$dur <- 28*(ko$duration == "4wk")
ko <- ko[,c('BVTV','BMD','trab.sep','trab.num','MSBS','OCSBS','BFRBS','load.max','load.fail','unload','dur')]
ko <- na.omit(ko)

# Keep only 4-week duration animals
ko <- ko[ko$dur == 28, ]

# Transform to numeric
ko$BVTV <- as.numeric(as.character(ko$BVTV))
ko$BMD <- as.numeric(as.character(ko$BMD))
ko$trab.sep <- as.numeric(as.character(ko$trab.sep))
ko$trab.num <- as.numeric(as.character(ko$trab.num))
# Convert to numeric
ko <- ko %>%
  dplyr::mutate_at(vars(1:11), ~as.numeric(as.character(.)))
print(ko)
# Normalize between -1 and 1
# Find the minimum and maximum values in the dataframe
ko_min <- apply(ko, 2, min)
ko_max <- apply(ko, 2, max)

# Define the desired range for normalization (-1 and 1)
new_min <- 0
new_max <- 1

# Perform Min-Max scaling for each column in the dataframe
for (col in colnames(ko)) {
  # Check if X_max - X_min is zero for the current column
  if (ko_max[col] - ko_min[col] != 0) {
    ko[, col] <- ((ko[, col] - ko_min[col]) / (ko_max[col] - ko_min[col])) * (new_max - new_min) + new_min
  } else {
    # Handle the case where all values are the same in the column
    # Set all values to a constant value (e.g., 0 or any other value you prefer)
    ko[, col] <- 1
  }
}

print(ko)
# PCA
mass <- pca(r=ko[,c("BVTV","BMD")], nfactors = 1, scores = T)
trab <- pca(r=ko[,c("trab.sep","trab.num")], nfactors = 1, scores = T)
form   <- pca(r=ko[,c("MSBS","BFRBS")], nfactors = 1, scores = T)
stren <- pca(r=ko[,c("load.max","load.fail")], nfactors = 1, scores = T)

ko$mass <- as.vector(mass$scores[,1])
ko$trab <- as.vector(trab$scores[,1])
ko$stren <- as.vector(stren$scores[,1])
ko$expose <- ((ko$unload*ko$dur)-mean(ko$unload*ko$dur))/(sd(ko$unload*ko$dur))
ko$resorp <- scale(ko$OCSBS)
ko$form   <- as.vector(form$scores)

# Rename and pare down dataframe to only contain relevant variables
ko <- ko[,c("unload","dur","expose","mass","trab","stren","resorp","form")]
rm(list=c("mass","trab","form","stren"))

# Grow-Shrink
ko_dag <- bnlearn::gs(ko)
graph_dag <- bnlearn::as.graphNEL(ko_dag)

# Plotting the DAG
plot(graph_dag)
text(x = 100, y = 500, labels = "Ko (2/2) DAG", font = 4)
