#!/bin/bash

#SBATCH --time=12:00:00
#SBATCH --nodes=3
#SBATCH --tasks-per-node=8
#SBATCH -p normal

if [ "$#" -ne 1 ]; then
    echo "Usage: submit_mpi_experiment.sh <output_exec>"
    exit
fi

module load MCR/R2018a
export MCR_CACHE_ROOT=`mktemp -d /scratch-local/mcr.XXXXXX`

echo "running ./interface" $1

srun -n 24 ./interface $1
