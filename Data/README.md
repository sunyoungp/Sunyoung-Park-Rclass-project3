# Data Folder

The folders in Data should contain all of the data used in this project. 

The `Data` is being loaded/manipulated/reshaped/saved using code from the `Code` folder. 

## Raw Data

Raw data goes in the `Raw_data` folder.

Data cleaning is done in code, which archives of all of the cleaning steps.


### Data Entry Check

Festuca Mairei, Unidentified shrub and Unplanted weed were eliminated from the list of species due to its inadequate sample size and lack of identification. 
Now there is 11 plant species, instead of 14 species, for analysis.
These are documented in `directory_root/Code/Processing_code/processingcode.R`


## Cleaned Data

`Processed_data` contains the cleaned version of the data. 


* `processeddata.rda` is the cleaned version of the data.
* `processeddata.csv` is the cleaned version of the data.
* `dictionary.csv` is a data dictionary for the cleaned data.
