# PowerModelsPrivacyPreserving.jl

PowerModelsPrivacyPreserving.jl is an extension package of PowerModels.jl, to obfuscate values in privacy sensitive (optimal) power flow data sets. The [youtube talk](https://www.youtube.com/watch?v=AEEzt3IjLaM) on PowerModels is a recommended watch. 

## Paper Reference
https://arxiv.org/abs/2103.14036

## Problem Statement
For the modeling, design and planning of future energy transmission networks, it is vital for stakeholders to access faithful and useful power flow data, while provably maintaining the privacy of business confidentiality of service providers. This critical challenge has recently been somewhat addressed in [1]. This paper significantly extends this existing work. First, we reduce the potential leakage information by proposing a fundamentally different post-processing method, using public information of grid losses rather than power dispatch, which achieve a higher level of privacy protection. Second, we protect more sensitive parameters, i.e., branch shunt susceptance in addition to series impedance (complete pi-model). This protects power flow data for the transmission high-voltage networks, using differentially private transformations that maintain the optimal power flow consistent with, and faithful to, expected model behaviour. Third, we tested our approach at a larger scale than previous work, using the PGLib-OPF test cases [10]. This resulted in the successful obfuscation of up to a 4700-bus system, which can be successfully solved with faithfulness of parameters and good utility to data analysts. Our approach addresses a more feasible and realistic scenario, and provides higher than state-ofthe-art privacy guarantees, while maintaining solvability, fidelity and feasibility of the system.

1: https://arxiv.org/abs/1901.06949

## Installation and setup for development
### Using Github desktop first
Clone the package through github desktop to a local folder.
Enter package model through `]`. Run `(v1.3) pkg> develop --local "path/to/local/project_folder"`. You can confirm it's working if you see PowerModelsPrivacyPreserving in the list by running `(v1.3) pkg> status`.

### Using the built-in package manager first
Install using the built-in package manager `(v1.3) pkg> add https://github.com/frederikgeth/PowerModelsPrivacyPreserving.jl.git`. Then put it in development mode through `(v1.3) pkg> add develop PowerModelsPrivacyPreserving`. Then you can point Github Dekstop to the julia dev folder. Go to  `File -> Add local repository ...`  in Github Dekstop and then browse to `~\.julia\dev\PowerModelsPrivacyPreserving`. 

### Package development in Julia
See https://www.youtube.com/watch?v=QVmU29rCjaA for an introduction to package development in Julia.

## Use enviroments
In package mode, in the root of PowerModelsPrivacyPreserving, write `activate ./` to create an environment for the project. Run `activate` to go back to the root.

## Core Problem Specifications

- Optimal Power Flow (opf) with maximum load delivery
- OPF with variable branch impedance to obfuscate impedance data

## Core Network Formulations

- AC polar (balanced)


## Network Data Formats

- Matlab ".m" files

**Warning:** This package is under active development and may change drastically without warning.

## Development

Please develop in a branch (or a fork) of this repo, and launch pull requests to integrate the code into master (don't commit straight to master). Then assign a reviewer, and ask for a review. Only merge after approval. 

Some guidelines on where to put code:
- All the package code goes into `src`
- All the unit test code `test`, and unit test data goes into `test\data`
- Scripts go into `examples`
- Don't add things to the root folder

## Examples
Examples can be found in the examples/test_all_datasets.jl file. The function check_dataset_perturbation contains a testing script to produce a comparison of solutions for the original dataset, and the perturbed datasets given input parameters.

The function check_dataset_perturbation accepts the following inputs:
test_directory: The directory where the test cases are located
output_directory: The directory to save output results to
filename: The filename of the test case
α: Indistinguishability value (refer to paper)
β: Objective faithfulness value (refer to paper)
ϵ: Privacy budget (refer to paper)
λ: Optimization constraint scale factor (refer to paper)

The solution will be saved to the provided output_directory/ and can be inspected.

## Acknowledgments

This code has been developed as part of the Privacy-Preserving Technology Energy Pilot Study at Data61/CSIRO Energy. Contributors include:

- Andrew Feutrill (@afeutrill)
- David Smith (@davidsmith2020)
- Elliot Vercoe (@elliottd61)
- Frederik Geth (@frederikgeth)
- Jonathan Chan (@cha425)
- Ming Ding (@MingDing2019)

## License

This code is provided under a BSD license as part of the "Privacy-Preserving Technologies Energy Pilot Study"
