#!/bin/bash

##For KS experiments:
##SBATCH --time=1:30:00
##SBATCH --ntasks=50
##SBATCH --mem-per-cpu=20GB

# For QG experiments:
#SBATCH --time=4:00:00
#SBATCH --ntasks=50
#SBATCH --mem-per-cpu=24GB

### A short test (QG)
##SBATCH --ntasks=5
##SBATCH --mem-per-cpu=13GB
##SBATCH --partition=short

#### A short test (QG)
##SBATCH --ntasks=90
##SBATCH --mem-per-cpu=10GB
##SBATCH --partition=short

##### A short test (KS)
##SBATCH --ntasks=50
##SBATCH --mem-per-cpu=20GB
##SBATCH --partition=short

if [ "$#" -ne 1 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec>"
    exit
fi

module load MATLAB/2018a
# export MCR_CACHE_ROOT=`mktemp -d ~/scratch-local/mcr.XXXXXX`

echo "running ./interface" $1

srun -n 50 ./interface $1
