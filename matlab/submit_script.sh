#!/bin/bash

# Just to submit ordinary matlab scripts, nothing in parallel

# # testing:
# #SBATCH --time=00:05:00
# #SBATCH --partition=short
# #SBATCH --output=matlab.out

#SBATCH --time=100:00:00

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --job-name=qg_spinup
#SBATCH --mem=64G

module load MATLAB/2018a
matlab -nodisplay < QG_Spinup.m
