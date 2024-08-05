# misc
Random notes, scripts, et cetera

This repository contains:
- Notes on compiling WRF for an Urban setup on Snellius and submission scipt for compilation. `PK_WRF_compile_notes.sh` & `PK_compile_wrf.sh`
- Example notebooks for plotting WRF data using the wrf-python package: `plot-wrf-cartopy.ipynb`, `wrf-python-plots.ipynb`.
- A more specific notebook plotting `geo_em` files comparing different input datasets: `plot_geo_em.ipynb`
- `wrf-runner` directory containing bash scripts to run WRF with experiments
- `worksflows/snakemake` contains snakemake workflow for running experiments automatically. 
    - Contains `Snakefile` with workflow rules, configuration file `config.yaml`, experiment input namelists and geogrid tables for WRF as well as `experiments.md` describing the experiments being run. 