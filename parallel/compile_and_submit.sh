#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./compile_and_submit.sh <matlab_file> <build_dir>"
    exit
fi

# check for matlab compiler existence
mcc_path=$(which mcc)
on_cluster=0
if [ -x "$mcc_path" ];
then
    echo "matlab compiler available at" $mcc_path
else
    #assume we're on a cluster
    on_cluster=1
    echo "loading matlab compiler module"
    module load MATLAB/2018a
    module load MCR/R2018a
fi


if [ $on_cluster -eq 1 ]
then
   export MCR_CACHE_ROOT=`mktemp -d /scratch-local/mcr.XXXXXX`
fi

output_exec=run

#if ! [[ -s $2/$output_exec ]]
#then
mkdir -p $2
mcc -R -singleCompThread -v -C -m $1 -d $2 -a ../matlab \
    -a ~/local/matlab -a ~/Projects/ESN/matlab/ESN.m \
    -o $output_exec
#else
#    echo "found executable" $2/$output_exec
#fi

interface_src=interface.cc
cp -v $interface_src $2/.

if [ $on_cluster -eq 1 ]
then
    cp -v submit_mpi_experiment.sh $2/.
fi

cd $2

mpicxx -Wall $interface_src -o interface -lmpi

if [ $on_cluster -eq 1 ]
then
    sbatch submit_mpi_experiment.sh
else
    mpirun -np 4 ./interface $output_exec
fi
