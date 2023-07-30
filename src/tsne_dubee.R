library(dplyr)
library(bnlearn)
library(Rgraphviz)
library(Rtsne)
library(psych)

set.seed(123)

# If the user has downloaded the data locally
data_dir <- "../data"

if(dir.exists(data_dir))
{
  path_lsds_15 <- file.path(data_dir, "LSDS-15_microCT_alwoodTRANSFORMED.csv")
  data_lsds_15 <- read.csv(path_lsds_15, header = TRUE)
  print("Loaded from existing file")
} else
{
  path_lsds_15 <- file.choose()
  data_lsds_15 <- read.csv(path_lsds_15, header = TRUE)
}

dubee <- data_lsds_15[c(3:6,9)]

# TSNE on Exposure Type (expose)
dubee$Factor.Value <- ifelse(data_lsds_15$Factor.Value=="Flight",1, 0)
tsne_out <- Rtsne::Rtsne(dubee, perplexity=5, pca = FALSE)
class_colors <- ifelse(dubee$Factor.Value == 0, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Dubee TSNE on Expose BEFORE Composite Variables, perplexity = 5", xlab = "X", ylab = "Y")
legend("bottomright", legend = c("Expose = Control", "Expose = Flight"), 
       col = c("blue", "red"), pch = 1)

names(dubee)[1:5] <- c("expose", "thick", "sep", "num", "bvtv")

# Trabecular Architecture (trab)
trab <- psych::pca(r=dubee[,c("sep", "num")],nfactors=1, scores=T)
mass <- psych::pca(r=dubee[,c("thick","bvtv")],nfactors=1,scores=T)

dubee$trab <- BiocGenerics::as.vector(trab$scores)
dubee$mass <- BiocGenerics::as.vector(mass$scores)

# TSNE on exposure with composite variables
dubee <- dubee[,c("expose", "trab", "mass")]
tsne_out <- Rtsne::Rtsne(dubee, perplexity=5, pca = FALSE)
class_colors <- ifelse(dubee$expose == 0, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Dubee TSNE on Expose given Composite Variables, perplexity = 5", xlab = "X", ylab = "Y")
legend("bottomleft", legend = c("Expose = Control", "Expose = Flight"), 
       col = c("blue", "red"), pch = 1)

# TSNE on mass with composite variables
tsne_out <- Rtsne::Rtsne(dubee, perplexity=5, pca = FALSE)
class_colors <- ifelse(dubee$mass < 0, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Dubee TSNE on Mass given Composite Variables, perplexity = 5", xlab = "X", ylab = "Y")
legend("topleft", legend = c("Mass post-PCA < 0", "Mass post-PCA >= 0"), 
       col = c("blue", "red"), pch = 1)

# TSNE on trab with composite variables
tsne_out <- Rtsne::Rtsne(dubee, perplexity=5, pca = FALSE)
class_colors <- ifelse(dubee$trab < 0, "blue", "red")
plot(tsne_out$Y,col=class_colors,asp=1,
     main = "Dubee TSNE on Trab given Composite Variables, perplexity = 5", xlab = "X", ylab = "Y")
legend("topleft", legend = c("Trab post-PCA < 0", "Trab post-PCA >= 0"), 
       col = c("blue", "red"), pch = 1)