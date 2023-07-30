# Replicating Results with R Script Files
Each of the datasets mentioned in the repository level README.md will be accessible with random seeds set for reproducing results.

## TSNE Visualization of Structures in Datasets 📊
Filenames prefixed with `tsne` are meant to read in data and create 2D plots to examine any significant clustering in the data.
The inline documentation should be sufficient for reproducing results, but read on if you would like to know more about the specifics for the parameters chosen.

### TSNE without PCA
Due to the small size of the datasets used in this project, additional PCA is not performed on the inputs to TSNE. 
If you would like to try doing so, refer to the reference manual for [Rtsne](https://cran.r-project.org/web/packages/Rtsne/Rtsne.pdf).
PCA is already performed on some of the variables to create composite variables to try and infer if the approach to generate DAGs is detailed enough.

### Perplexity Value in TSNE
The perplexity values used in these implementations are either 5 or 10. These are relatively small values, 
and were a necessary adjustment because the dataset is too small for a perplexity greater than 12 (it will likely result in a compiler error).
A lower perplexity value influences TSNE by adjusting its focus on preserving local structures, which intuitively seems like a valid approach due to our dataset size.

## Authors 📚
- Jake Campbell
