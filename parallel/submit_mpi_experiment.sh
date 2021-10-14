#!/bin/bash

#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --partition=short
#SBATCH --mem-per-cpu=10GB

if [ "$#" -ne 1 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec>"
    exit
fi

module load MATLAB/2018a
export MCR_CACHE_ROOT=`mktemp -d ~/scratch-local/mcr.XXXXXX`

echo "running ./interface" $1

srun -n 5 ./interface $1
