# DAG ML: Grow-Shrink
![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white) ![RStudio](https://img.shields.io/badge/RStudio-4285F4?style=for-the-badge&logo=rstudio&logoColor=white) 

Building off of the findings of ["Validating Causal Diagrams of Human Health Risks for Spaceflight: An Example Using Bone Data from Rodents,"](https://www.mdpi.com/1813442) this project explores, in collaboration with the authors of this study, to explore Machine Learning approaches to generate Directed Acyclic Graphs using the [Grow-Shrink Algorithm](https://doi.org/10.48550/arXiv.1407.8088).

## Getting Started 👩‍🚀👨‍🚀
You can get started by cloning the repository and running `notebooks/growshrink_notebook.Rmd` in RStudio or VS Code. The file `notebooks/growshrink_notebook.nb.html` can also be downloaded to read through the file as a learning resource in your web browser. 

The output graphs of Grow-Shrink, and an Exploratory Data Analysis are available in the `graphs/` directory.

## Objectives/Road Map 🚀
- [ ] Generate a DAG that can be validated or invalidated by a domain expert
- [ ] Identify or develop a validity score that can measure the degree of congruency with another graph
- [ ] Determine Grow-Shrink's level of adaptability to generate DAGs for HSRB medical risk assessment for astronauts
- [ ] Ensure that DAGs are ML-ready -- can they be used to fit the parameters to a Bayesian Network?

    ### Additional Objectives/Stretch Goals
    - [ ] Rewrite `notebooks/growshrink_notebook.Rmd` as an R Script file
    - [ ] Convert source code to Python or C++ for further reusability
    - [ ] Generalize code for any dataset that meets standards for OSDR's TRANSFORMED datasets

## Data 🐭
All data from this project is publicly available through [NASA's Open Science Data Repositories](https://osdr.nasa.gov/bio/). If you would like to automate the use of data please download the following CSV files and place them in a directory called `data/` on the same level as the `notebooks/` directory. The notebook will use this structure to load the files relatively from the R Notebook file for you. Otherwise, you will be prompted to load the files through a file explorer.
- [Quantifying Cancellous Bone Structural Changes in Microgravity: Axial Skeleton Results from the RR-1 Mission](https://doi.org/10.26030/8wja-w380) (Dubeé, 2022)
- [Effects of Spaceflight on Bone Microarchitecture in the Axial and Appendicular Skeleton in Growing Ovariectomized Rats from STS-62](https://doi.org/10.26030/cztm-cx29) (Keune, 2015)
- [Spaceflight-induced (STS-62) vertebral bone loss in ovariectomized rats is associated with increased bone marrow adiposity and no change in bone formation](https://doi.org/10.26030/kb2k-2150) (Keune, 2016)
- [Dose-dependent skeletal deficits due to varied reductions in mechanical loading in rats (Tibia - pQCT)](https://doi.org/10.26030/emsm-0648) (Ko, 2020) 1/2
    - Use of this data is TBD by findings of microCT data below
- [Dose-dependent skeletal deficits due to varied reductions in mechanical loading in rats (Femur - microCT, three-point bending, histomorphometry)](https://doi.org/10.26030/b09t-mw60) (Ko, 2020) 2/2

## Dependencies 💾
The following libraries are used in the notebooks associated with the project
- [dplyr](https://dplyr.tidyverse.org/)
- [bnlearn](https://www.bnlearn.com/)
- [Rgraphviz](http://bioconductor.org/packages/release/bioc/html/Rgraphviz.html)
- [psych](https://cran.r-project.org/web/packages/psych/index.html)
