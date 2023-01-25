# hybrid_om 
Framework for hybrid ocean modeling experiments with a
physics-controlled ESN.

# dependencies
 - QG (matlab/c++ implementation)
 - ESN: [![DOI](https://zenodo.org/badge/265245681.svg)](https://zenodo.org/badge/latestdoi/265245681)

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
