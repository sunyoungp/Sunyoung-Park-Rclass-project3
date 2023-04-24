###############################
# processing script
#
#this script loads the raw data, processes and cleans it 
#and saves it as Rds file in the Processed_data folder

## ---- packages --------
#load needed packages. make sure they are installed.
require(dplyr) #for data processing/cleaning
require(tidyr) #for data processing/cleaning
require(skimr) #for nice visualization of data 


## ---- loaddata1.1 --------
data_location <- "../../Data/Raw_data/plant_measurement_raw.csv"
data_path <- "../../Data/Raw_data/"

## ---- loaddata1.2 --------
rawdata <- read.csv(data_location, check.names=FALSE)

## ---- loaddata1.3 --------

# We can look in the data dictionary for a variable explanation. I am using the paste function here to add the path to the filename.

sep=“” adds no space when pasting.
dictionary <- read.csv(paste(data_path, "datadictionary.csv", sep=""))
print(dictionary)



## ---- exploredata --------

# Different ways to look at the data

dplyr::glimpse(rawdata)

summary(rawdata)

head(rawdata)

skimr::skim(rawdata)


## ---- exploredata2 --------

# We temporarily change the variable names to short names in this script for convenience. 

longnames <- names(rawdata)
names(rawdata) <- c("Date", "Time", "Sample number", "Location", "Type", "Treatment", "Size", "Species", "Plant type", "Height", "Width_farthest", "Width_perpendicular", "Branch_length", "Branch_diameter", "Basal_circ", "Stem_diameter", "Stem_height", "Stem_density", "Branches_per_stem", "Leaves_per_branch", "Total_leaves", "Leaf_lmax", "Leaf_lmin", "Leaf_lavg", "Leaf_wmax", "Leaf_wmin", "Leaf_wavg", "Leaf_tmax", "Leaf_tmin", "Leaf_tavg", "Biomass", "Measurement_location", "Note", "leaf: branch (total; biomass)", "leaf: branch (single branch; biomass)")


## ---- cleandata1 --------

# We check to make sure there is 14 species of plants for the dataset.

unique(rawdata$Species)

# Letʻs save rawdata as d1, and modify d1 so we can compare versions. 

d1 <- rawdata
unique(d1$Species)


## ---- cleandata2 -------- 

# Get rid of date and time, notes, 'Leaf: branch (total; biomass)' and 'Leaf: branch (single; biomass)' from the column
# We don't need it for our analysis.
d1 <- d1[,3:32]


# Turn any blanks or n/a's into NA
d1[d1==""] <- NA
d1[d1=="n/a"] <- NA


#coerce all the entries of the morphological measurement variables to numeric
num <- c(8:29)
d1[,num] <- apply(d1[,num], 2, function(x) as.numeric(as.character(x)))

skimr::skim(d1)


## ---- cleandata3 -------- 

# We turn species into a categorical variable.

d1$Species <- as.character(d1$Species)

# We want to separate the measurements by species so we can look at morph measurements that correlate with the biomass of each species. 

# We split the plant (d1) dataframe into a list of dataframes (aka spec) by species. 
spec <- with(d1, split(d1, list(Species = Species)))
spec <- lapply(spec, function(x) x[, colSums(is.na(x)) == 0])

spec


## ---- cleandata4 -------- 

# Look at each species and their morph measurements
# Since Festuca Mairei only has three samples, we are going to eliminate it from the sample species, due to not enough sample size.

Rows <- which(grepl("Festuca Mairei", d1$Species))
d1 <- d1[-c(Rows),]
d1


# Redefine spec with a new list of species (excluding Festuca Mairei). 
spec <- with(d1, split(d1, list(Species = Species)))
spec <- lapply(spec, function(x) x[, colSums(is.na(x)) == 0])

spec



## ---- savedata --------

# Save the clean data as processed data
# We save d1, which is a dataframe as the clean data and will convert to spec, which is a list, on analysis script for data analysis.

processeddata <- d1      # clean data


## ---- savedata2 --------

# Location to save file

# We save the clean data as RDS file, as well as a copy as .csv.
# RDS/Rdata preserves coding like factors, characters, numeric, etc.

save_data_location <- "../../Data/Processed_data/processeddata.rds"
saveRDS(processeddata, file = save_data_location)

save_data_location_csv <- "../../Data/Processed_data/processeddata.csv"
write.csv(processeddata, file = save_data_location_csv, row.names=FALSE)






#############################

# test for normality
# a normal distribution is an assumption for a lot of statistical tests
# this part of the code tests for normality using a Shapiro Test
# the loop tests for normality in each species in the same order the dataframes are listed in spec


### the below is how you test for normality by species one at a time

print(shapiro.test(spec[["Aptenia cordifolia"]]$Biomass))
print(shapiro.test(spec[["Artemisia californica"]]$Biomass))
print(shapiro.test(spec[["Baccharis pilularis"]]$Biomass))
print(shapiro.test(spec[["Chondropetalum tectorum"]]$Biomass))
print(shapiro.test(spec[["Euphorbia spp."]]$Biomass))
print(shapiro.test(spec[["Gnaphaluim spp."]]$Biomass))
print(shapiro.test(spec[["Lactucca spp."]]$Biomass))
print(shapiro.test(spec[["Onetheria biennis"]]$Biomass))
print(shapiro.test(spec[["Rhus integrifolia"]]$Biomass))
print(shapiro.test(spec[["Salix spp."]]$Biomass))
print(shapiro.test(spec[["Solidago spp."]]$Biomass))
print(shapiro.test(spec[["Unidentified shrub"]]$Biomass))
print(shapiro.test(spec[["Unplanted weed"]]$Biomass))


##normally distributed data (p > 0.05): Aptenia cordifolia, Artemisia californica, Chondropetalum tectorum, #Gnaphaluim spp., Rhus integrifolia, Solidago spp., Unidentified shrub


##not normally distributed data (p < 0.05): Baccharis pilularis, Euphorbia spp., Lactucca spp., Onetheria #biennis, Salix spp., Unplanted weed



#Look at each species and its morphological measurements to see which measurement(s) would be a good biomass indicator for each species. Then we can test with a regular linear regression model for normally distributed data. 

spec

##Aptenia cordifolia: test for leaves per branch measurements

m1 <- lm(Biomass ~ Leaves_per_branch,
data= spec [["Aptenia cordifolia"]])
summary(m1)

### R-squared value is 0.3025 and p-value is 0.07236, which means that the model doesn't explain the variation of the data and it is also not significant.

##Aptenia cordifolia: test for branch length measurements

m1 <- lm(Biomass ~ Branch_length,
data= spec [["Aptenia cordifolia"]])
summary(m1)

### R-squared value is 0.7172 and p-value is 0.002438, which means that the model relatively explains the variation of the data (fits the regression model) and it is also significant. This morphological characteristic might be a good biomass indicator for Aptenia cordifolia.


##Artemisia californica: test for width perpendicular measurements
m1 <- lm(Biomass ~ Width_perpendicular,
data= spec[["Artemisia californica"]])
summary(m1)


### R-squared value is 0.9425 and p-value is 0.0008057, which means that the model does explain the variation of the data (fits the regression model) and it is also significant. This morphological characteristic might be a good biomass indicator for Artemisia californica.

m1 <- lm(Biomass ~ Width_perpendicular + Width_farthest,
data= spec[["Artemisia californica"]])
summary(m1)

m1 <- lm(Biomass ~ Width_perpendicular + Width_farthest + Branches_per_stem,
data= spec[["Artemisia californica"]])
summary(m1)

m1 <- lm(Biomass ~ Width_perpendicular + Branches_per_stem,
data= spec[["Artemisia californica"]])
summary(m1)