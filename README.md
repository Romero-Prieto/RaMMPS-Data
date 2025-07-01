This is a code repository for the manuscript “2022–23 Malawi Rapid Mortality Mobile Phone Survey (RaMMPS) dataset”, which is currently under review.

The MATLAB file RaMMPS_data.m produces the three tables included in the manuscript, using some input data files: RaMMPSdst.csv, DHSmalawidst.csv, and RaMMPScalls.csv.

These data files are not part of this repository but can be consolidated after running the Stata do-file RaMMPS_processing.do, available at https://github.com/Romero-Prieto/RaMMPS_U5M (also within this GitHub account).

This routine requires the following raw data files, available from these repositories:

MW_AnalyticSample.dta and MW_AllCallAttempts.dta from DataFirst, the RaMMPS project data repository, available at: https://doi.org/10.25828/M86Z-NF08
MWIR7AFL.dta, MWBR7AFL.dta, and MWPR7AFL.dta, from the 2015–16 Malawi Demographic and Health Survey by the DHS Program, available at: https://dhsprogram.com
hh.sav, wm.sav, and bh.sav, from the 2019–20 Malawi Multiple Indicator Cluster Survey by UNICEF MICS, available at: https://mics.unicef.org

The do-file and m-file run automatically from top to bottom, but the user may need to adjust the file paths for reading the data and saving the outputs.
