#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: ./compile_and_submit.sh <matlab_file> <build_dir> <numproc>"
    exit
fi

# check for matlab compiler existence
mcc_path=$(which mcc)
ret_code=$?

if [ $ret_code -eq 0 ];
then
    echo "matlab compiler available at" $mcc_path
    on_cluster=0
else
    #assume we're on a cluster and matlab needs loading
    on_cluster=1
    echo "loading MATLAB"
    module load MATLAB
fi

#if [ $on_cluster -eq 1 ]
#then
#    export MCR_CACHE_ROOT=`mktemp -d ~/scratch-local/mcr.XXXXXX`
#fi

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
        -a ~/local/matlab -a ../../ESN/matlab/ESN.m \
        -o $output_exec
    sleep 1
else
    echo "found executable" $2/$output_exec
fi

interface_src=interface.cc
cp -v $interface_src $2/.

if [ $on_cluster -eq 1 ]
then
    cp -v submit_mpi_experiment.sh $2/.
    echo "loading foss"
    module load foss
fi

cd $2

# compile the interface
mpicxx -Wall $interface_src -o interface -lmpi
sleep 1
ret_code=$?
if [ $ret_code -eq 1 ]
then
   echo "compilation failed"
   exit
fi

if [ $on_cluster -eq 1 ]
then
    for (( i=0; i<$3; i++ ))
    do
        echo "Submitting job $i of $3";
        sbatch submit_mpi_experiment.sh $output_exec $i $3;
    done
    sleep 1
else
    mpirun --oversubscribe -np $3 ./interface $output_exec
fi
