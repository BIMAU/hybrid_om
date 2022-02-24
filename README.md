# hybrid_om 
Framework for hybrid ocean modeling experiments with a
physics-controlled ESN.

# dependencies
 - QG (matlab/c++ implementation)
 - ESN: https://github.com/erik808/ESN

# usage notes:
- Adjust the `base_dir` in `DataGen`

## executables
- `matlab/KS_GridExp`
- `matlab/KS_Path2018`
- `matlab/QG_GridExp`
- `matlab/QG_transient`
    
## parallel execution
- set job settings in `submit_mpi_experiment.sh`
- `./compile_and_submit <executable> <run_dir>`
