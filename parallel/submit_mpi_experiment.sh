#!/bin/bash

##For KS experiments:
##SBATCH --time=1:30:00
##SBATCH --ntasks=50
##SBATCH --mem-per-cpu=20GB

# For QG experiments:
#SBATCH --time=4:00:00
#SBATCH --ntasks=1
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

if [ "$#" -ne 3 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec> <pid> <numproc>"
    exit
fi

module load foss/2018a
module load MATLAB/2018a
# export MCR_CACHE_ROOT=`mktemp -d ~/scratch-local/mcr.XXXXXX`

echo "running " $1 $2 $3

srun $1 $2 $3
