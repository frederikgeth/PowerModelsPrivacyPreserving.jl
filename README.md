# PowerModelsPrivacyPreserving.jl

PowerModelsPrivacyPreserving.jl is an extension package of PowerModels.jl, to obfuscate values in privacy sensitive (optimal) power flow data sets. The [youtube talk](https://www.youtube.com/watch?v=AEEzt3IjLaM) on PowerModels is a recommended watch. 

## Installation and setup for development
### Using Github desktop first
Clone the package through github desktop to a local folder.
Enter package model through `]`. Run `(v1.3) pkg> develop --local "path/to/local/project_folder"`. You can confirm it's working if you see PowerModelsPrivacyPreserving in the list by running `(v1.3) pkg> status`.

### Using the built-in package manager first
Install using the built-in package manager `(v1.3) pkg> add https://github.com/frederikgeth/PowerModelsPrivacyPreserving.jl.git`. Then put it in development mode through `(v1.3) pkg> add develop PowerModelsPrivacyPreserving`. Then you can point Github Dekstop to the julia dev folder. Go to  `File -> Add local repository ...`  in Github Dekstop and then browse to `~\.julia\dev\PowerModelsPrivacyPreserving`. 

### Package development in Julia
See https://www.youtube.com/watch?v=QVmU29rCjaA for an introduction to package development in Julia.

## Core Problem Specifications

- Optimal Power Flow (opf) with maximum load delivery
- OPF with variable branch impedance to obfuscate impedance data

## Core Network Formulations

- AC polar (balanced)


## Network Data Formats

- Matlab ".m" files

**Warning:** This package is under active development and may change drastically without warning.

## Development

Community-driven development and enhancement of PowerModelsPrivacyPreserving are welcome and encouraged. Please develop in a fork or branch of this repo, and launch pull requests to integrate the code into master.

## Acknowledgments

This code has been developed as part of the Privacy-Preserving Technology Energy Pilot Study at Data61/CSIRO Energy. Contributors include:

- Andrew Feutrill (@afeutrill)
- David Smith (@davidsmith2020)
- Elliot Vercoe (@elliottd61)
- Frederik Geth (@frederikgeth)
- Jonathan Chan (@cha425)
- Ming Ding (@MingDing2019)

## License

TBD
