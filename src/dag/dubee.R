library(dplyr)
library(bnlearn)
library(Rgraphviz)
library(psych)

set.seed(123)

# If the user has downloaded the data locally
data_dir <- "../../data"

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

# Exposure Type (expose)
dubee$expose <- ifelse(data_lsds_15$Factor.Value=="Flight",1, 0)
  names(dubee)[2:5] <- c("thick", "sep", "num", "bvtv")

# Trabecular Architecture (trab)
trab <- psych::pca(r=dubee[,c("sep", "num")],nfactors=1, scores=T)
mass <- psych::pca(r=dubee[,c("thick","bvtv")],nfactors=1,scores=T)

dubee$trab <- BiocGenerics::as.vector(trab$scores)
dubee$mass <- BiocGenerics::as.vector(mass$scores)

dubee <- dubee[,c("expose", "trab", "mass")]

dubee_nel <- bnlearn::gs(dubee, debug = TRUE)

dubee_graph <- bnlearn::as.graphNEL(dubee_nel)

Rgraphviz::plot(dubee_graph, name="Dubee")