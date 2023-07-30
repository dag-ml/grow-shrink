# Author        - Jacob Campbell
# Project       - ML DAG: Grow-Shrink (Ko Data)
# Last Updated  - 7/30/23

library(dplyr)      # various helper functions
library(bnlearn)    # gs, some graph utilities
library(Rgraphviz)  # graph utilities
library(psych)      # pca
library(Rtsne)

set.seed(123)
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
ko$dur   <- 7*(ko$duration=='1wk')+14*(ko$duration=='2wk')+28*(ko$duration=='4wk')
ko <- ko[,c('BVTV','BMD','trab.sep','trab.num','MSBS','OCSBS','BFRBS','load.max','load.fail','unload','dur')]

# Transform to numeric
ko$BVTV <- as.numeric(as.character(ko$BVTV))
ko$BMD <- as.numeric(as.character(ko$BMD))
ko$trab.sep <- as.numeric(as.character(ko$trab.sep))
ko$trab.num <- as.numeric(as.character(ko$trab.num))

# Convert to numeric (fool-proof version)
ko <- ko %>%
  dplyr::mutate_at(vars(1:11), ~as.numeric(as.character(.)))
ko <- na.omit(ko)

# TSNE without PCA, no composite variables (UNLOAD)
tsne_out <- Rtsne::Rtsne(ko, perplexity=10, pca = FALSE)
class_colors <- ifelse(ko$unload < 60, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Ko TSNE on Unload, perplexity = 10", xlab = "X", ylab = "Y")
legend("bottomright", legend = c("unload < 60", "unload >= 60"), col = c("blue", "red"), pch = 1)

# TSNE without PCA, no composite variables (DURATION)
tsne_out <- Rtsne::Rtsne(ko, perplexity=10, pca = FALSE)
class_colors <- ifelse(ko$dur < 28, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Ko TSNE on Duration, perplexity = 10", xlab = "X", ylab = "Y")
legend("topright", legend = c("duration < 4 weeks", "duration = 4 weeks"), 
       col = c("blue", "red"), pch = 1)

# PCA to create composite variables
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

# TSNE without PCA, using Composite Variables (UNLOAD)
tsne_out <- Rtsne::Rtsne(ko, perplexity=5, pca = FALSE)
class_colors <- ifelse(ko$unload < 60, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Ko TSNE on Unload with Composite Variables, perplexity = 10", xlab = "X", ylab = "Y")
legend("bottomright", legend = c("unload < 60", "unload >= 60"), col = c("blue", "red"), pch = 1)

# TSNE without PCA, using composite variables (DURATION)
tsne_out <- Rtsne::Rtsne(ko, perplexity=5, pca = FALSE)
class_colors <- ifelse(ko$dur < 28, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Ko TSNE on Duration with Composite Variables, perplexity = 10", xlab = "X", ylab = "Y")
legend("bottomright", legend = c("duration < 4 weeks", "duration = 4 weeks"), 
       col = c("blue", "red"), pch = 1)
