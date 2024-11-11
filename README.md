# Infrastructure Construction

This repository includes all scripts that are part of the Demscore Data Processing
Pipeline, i.e., scripts that generate thematic datasets, static reference documents,
and the variable files in numerous output units.

Internally, we refer to directories as *modules* and scripts as *tasks*. For instance,
**dataset_cleaning** is a module, while each dataset has its own **cleaning script**
i.e., task, within this module.

## Dataset Cleaning, Unit tables, and unit data generation

Scripts in the directories

* dataset_cleaning
* gen_unit_tables and

as well as the scripts 

* gen_primary_data and 
* gen_secondary_data

are the heart of the Demscore Data Processing pipeline. These steps are the most 
essential ones for every update, as they are required for the download interface 
to be updated with the most recent variables.  

item The Module *dataset_cleaning* runs a cleaning script script for every dataset, 
standardizing variable names, identifying the level of analysis for the dataset, 
creating unit columns (i.e. merge columns), eventually adjusting divergences in 
country names, and finally creating a cleaned version of the datasets as an .rds file. 

item The Module *gen_unit_tables* includes one script per unit table. The script 
loads all cleaned datasets included in that unit, binds the unit columns and 
saves a unit table grid with one distinct observation per identifier combination.  

item The *gen_primary_data* script creates one .rds file per variable in its primary 
output unit (determined by the output unit of the dataset the variable originates from).  

item The *gen_secondary_data* creates one .rds file per variable for every unit 
that is specified for a dataset as a secondary unit. 

Updating/adding a dataset requires to update the metatdata in the postgres database 
(variables, codebook entries, dataset information, etc), as well as updating/adding 
cleaning scripts, assigning the dataset a primary output unit, checking which 
secondary output units the dataset can be translated to, and updating the database 
accordingly (datasets, unit_trans and methodology table). 

## Static file creation
The creation of static files, such as thematic datasets, the static dataset files, 
project codebooks, etc, have also been added to the pipeline. This means that all 
these files are created automatically. Manual steps for these tasks are only create 
new codebook frontpages for each version to pick the relevant variables for new 
thematic datasets. This is done by creating a search term for the chosen topic and 
matching that with the metatdata in the postgres database. 

## Checks
Checks to ensure the generated data is correct are included in the pipeline as 
well. Checks are added whenever we discover a bug that could have been prevented 
by e.g. a unit test, more defensive programming, etc. 

## Pipeline extension
Demscore infrastructure is undergoing continuous improvement, such as improving 
the speed of individual scripts, add documentation, add new features to the 
pipeline, etc. The amount of time and effort this takes varies depending on the 
added Modules/Tasks. The main work on this ideally happen in between updates. As 
all scripts can be run individually, it is not absolutely necessary that a script 
is part of the pipeline. However, in terms of documentation, structure and ensuring 
the completeness of an update, that is highly desireable. 

## Server update
For every version update, we update two servers: 1) The development server to test 
the new data and rule out any problems with the download interface that cannot be 
discovered on the local PCs, and 2) the live server. 

The dev server is set up in the same way as the live server. On the development 
server, we update the data, relevant R scripts and R packages. On the live server, 
we update the data, relevant R scripts and R packages, as well as the data for 
the graphing tools. 
 

 

The version update also includes updating the graphing tools. In each website/version directory are four scripts that need to be run to update the online graphing tools. We currently only plot country year units. Extending the graphing tools  

 