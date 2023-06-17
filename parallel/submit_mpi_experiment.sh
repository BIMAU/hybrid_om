#!/bin/bash

#SBATCH --time=40:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=6GB

if [ "$#" -ne 3 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec> <pid> <numproc>"
    exit
fi

# module load foss
module load MATLAB
# export MCR_CACHE_ROOT=`mktemp -d ~/scratch-local/mcr.XXXXXX`

echo "running " $1 $2 $3

srun $1 $2 $3
