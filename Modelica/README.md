# Modelica package for AI DHC

The Modelica package requires 
- IBPSA v3.0.0
- AixLib v1.0.2, converted to MSL4

## Installation of required libs

2 options : use zip file or use GitHub repo

### Option 1 : from the zip file
1. Get the zip file from ${ProjectFolder}\50-Donnee Technique\AI-DHC-libs.zip
1. Unzip the file in the Modelica folder
3. This should create the following tree
    * lib
        * modelica-ibpsa
            * IBPSA
        * AixLib_MSL4
            * AixLib

### Option 2 : from GitHub
1. create folder "lib"
2. execute command
> git clone https://github.com/ibpsa/modelica-ibpsa.git

   NB: Revision used for initial import is 36c2bd1a
3. execute command
> git clone https://github.com/RWTH-EBC/AixLib.git

TODO : check used version for AixLib and how to convert to MSL4

## Usage of libraries

You can use the script loadLibraries.mos to load all required libraries
