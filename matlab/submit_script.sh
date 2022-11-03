#!/bin/bash

# Just to submit ordinary matlab scripts, nothing in parallel

# # testing:
# #SBATCH --time=00:05:00
# #SBATCH --partition=short
# #SBATCH --output=matlab.out

#SBATCH --time=24:00:00

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --job-name=qg_spinup
#SBATCH --mem=64G

module load MATLAB/2018a
matlab -nodisplay < QG_Spinup.m
