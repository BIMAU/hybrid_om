#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec>"
    exit
fi

#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --tasks=20
#SBATCH -p short

module load MCR/R2018a
export MCR_CACHE_ROOT=`mktemp -d /scratch-local/mcr.XXXXXX`

echo "running ./interface" $1

srun -n 20 ./interface $1
