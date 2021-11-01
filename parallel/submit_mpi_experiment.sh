#!/bin/bash

#SBATCH --time=0:30:00
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=short

if [ "$#" -ne 1 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec>"
    exit
fi

module load MATLAB/2018a
# export MCR_CACHE_ROOT=`mktemp -d ~/scratch-local/mcr.XXXXXX`

echo "running ./interface" $1

srun -n 16 ./interface $1
