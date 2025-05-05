# Stis-et-al.-2025
Wlcome to the GitHub for Stis et al. 2025! Available code for the Stis et al. 2025 manuscript is located in these files as described below.

**AUC_Analysis.m**
- Input: .xlsx file with time in minutes in first column and calcium data in remaining columns
- Goes through entire sheet for all columns in the specific sheet
- Outputs AUC for specified time range
- AUC will be adjusted based on either flat or decreasing baseline values to get accurate read of AUC values
 
**HighG_Peak_Counts.m**
- Input: .xlsx file with time in minutes in first column and calcium data in remaining columns
- Goes column by column to determine number of peaks and peaks per minute for specified time range
- Adjustments cna be made to peak finding algorithm with fixed variables at top of code

**Peak_Alignment_Cells_Islets.m**
- Input: .xlsx file with time in minutes in first column, islet calcium data in second column, and cell calcium data in third column
- Manually change sheet in excel document to go through different islets and their mathcing biosensor cells
- Outputs the phase shift as a percent of cell calcium peaks to islet calcium peaks
- Also outputs the actual times of islet and cell calcium peaks 
