# Cytometry-Biotechvana

Cytometry Biotechvana is a prototype of a Shiny application that allows an interactive workflow for flow cytometry data analysis. 

## Overview
Cytometry Biotechvana is a software application designed and developed by implementing different modules and flow cytometry packages written in R / Python / Java, and programming the different scripts and interfaces necessary to integrate the different modules as a final operational solution to a prototypical level. Through an interactive interface based on Shiny, the application allows a complete workflow, including pre-processing, data quality analysis, manual gating and six clustering algorithms (SOM, Kmeans, CLARA, Phenograph, Mclust and Hclust). The prototype has been tested against FCS files from two independent experiments to illustrate its utility, demonstrating to obtain relevant information for the final interpretation of the data. The present application serves as a starting point for future implementations, in which to integrate diagnostic algorithms or complex data visualization.

## Tutorial and requirements 

As a Shiny based app, Cytometry Biotechvana can be hosted on a server or run locally on your machine. In this case, the R session on the machine would act as the back end, whereas the web browser would be the front end.

Cytometry Biotechvana requires to have R, Python and Java installed on the system. The prototype has been developed using the version of R 4.0.5, Python 3.8.10 and Java (JDK) 11.0.11, so its use is recommended to avoid incompatibility problems of packages.

## Installation
The prototype script is prepared to automatically download all required R/python packages, however, it is possible to get the following warning message when installing it for the first time due to a "reticulate" package related issue (https://github.com/rstudio/reticulate/issues/607): 

>No non-system installation of Python could be found.
>Would you like to download and install Miniconda?
>Miniconda is an open source environment management system for Python.
>See https://docs.conda.io/en/latest/miniconda.html for more details.

>Would you like to install Miniconda? [Y/n]: 

If this is the case, select "n", and run your app again. All dependencies should be correctly installed and no more warning messages will arise concerning this issue.

## Remarks
The present work and prototype of Cytometry Biotechvana has been carried out under the framework of the master's thesis of the master's degree in Advanced Bioinformatics Analysis at the Pablo de Olavide University (Seville).

## References
Scripts and algorythms from different sources have been adapted and modified. Full list of references can be found on related paper. Though, mayor consulted sources were:  
Dai Y, Xu A, Li J, Wu L, Yu S, Chen J, et al. CytoTree: an R/Bioconductor package for analysis and visualization of flow and mass cytometry data. BMC Bioinformatics 2021, 22:1–20
Spidlen J, Barsky A, Breuer K, Carr P, Nazaire MD, Hill BA, et al. GenePattern flow cytometry suite. Source Code Biol Med 2013, 8:14
flowiQC_shinyAPP, A shiny app for interactive quality control of flow cytometry data https://github.com/SIgNBioinfo/flowiQC_shinyAPP
