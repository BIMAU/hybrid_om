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


# check whether we need to recompile
recompile=0
src_name=$1
md5_tmp=.md5tmp
m0=$(cat "$md5_tmp")
m1=$(md5sum "$src_name")
if [ "${m0:0:32}" != "${m1:0:32}" ]
then
    echo $src_name "has changed"
    echo ${m0:0:32}
    echo ${m1:0:32}
    recompile=1
else
    echo $src_name "not changed"
fi

echo $m1 > $md5_tmp

output_exec=run
if ! [[ -s $2/$output_exec ]] || [ $recompile -eq 1 ]
then
mkdir -p $2
mcc -R -singleCompThread -v -C -m $src_name -d $2 -a ../matlab \
    -a ~/local/matlab -a ~/Projects/ESN/matlab/ESN.m \
    -o $output_exec
else
    echo "found executable" $2/$output_exec
fi

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
    sbatch submit_mpi_experiment.sh $output_exec
else
    mpirun --oversubscribe -np 4 ./interface $output_exec
fi
