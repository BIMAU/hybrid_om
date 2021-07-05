#!/bin/bash

#SBATCH --time=00:59:00
#SBATCH --nodes=1
#SBATCH --tasks=24
#SBATCH -p short

if [ "$#" -ne 1 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec>"
    exit
fi

module load MCR/R2018a
export MCR_CACHE_ROOT=`mktemp -d /scratch-local/mcr.XXXXXX`

echo "running ./interface" $1

srun -n 24 ./interface $1
