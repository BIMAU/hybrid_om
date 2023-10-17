# Hybrid_om 
Framework for hybrid ocean modeling experiments with a physics-controlled ESN. The code here includes configurations for the Kuramoto-Sivashinsky (KS) equation and the quasi-geostrophic (QG) equations, with initial and boundary conditions as described in the paper "Symbiotic Ocean Modeling using Physics-Controlled Echo State Networks" (Mulder et.al., 2023). KS is implemented here and for QG we rely on the C++ code in `BIMAU/qg`. Our ESN is implemented in `erik808/ESN`.

# Dependencies
 - QG (matlab/c++ implementation) https://github.com/BIMAU/qg
 - ESN: https://github.com/erik808/ESN [![DOI](https://zenodo.org/badge/265245681.svg)](https://zenodo.org/badge/latestdoi/265245681)

# Usage notes:
- The code will require some adjustments before it will work somewhere else (some paths are still hardcoded). Most importantly the `base_dir` in `DataGen` needs adjusting.

## Executables
- `matlab/KS_GridExp` Subgrid scale modeling with the KS equation.
- `matlab/KS_Path2018` An experiment with KS reproducing the results in Pathak et.al., 2018.
- `matlab/QG_GridExp` Subgrid scale modeling with the QG equations.
- `matlab/QG_transient` Long-term transient computations with variants of a corrected imperfect QG. 
    
## Parallel execution
- set job settings in `submit_mpi_experiment.sh`
- `./compile_and_submit <executable> <run_dir>`
