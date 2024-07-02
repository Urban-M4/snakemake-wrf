# Snakemake

```
# Install micromamba on snellius
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
# During install, set conda-forge as default channel
source ~/.bashrc

# Create environment (pin 3.11 for ecmwflibs dependency of w2w)
micromamba create --name snakemake python=3.11 "numpy<2" bioconda::snakemake -y
micromamba activate snakemake
pip install git+https://github.com/matthiasdemuzere/w2w@add_wrf_version

# Make sure netcdf is available for WPS and WRF (these instructions are specific to Snellius)
module load 2023
module load netCDF-Fortran/4.6.1-gompi-2023a  # also loads gcc and gompi
export NETCDF=$(nf-config --prefix)

# Run snakefile in this dir
snakemake --dryrun  # just see if it looks okay
snakemake --cores 1  # execute on 1 core
snakemake --cores 1 REAL  # only execute up to and including REAL

# Potentially set up alias for snakemake to circumvent annoying design decision.
# https://github.com/snakemake/snakemake/issues/312
alias snakemake="snakemake --cores 1"

# Visualize DAG using graphviz
snakemake --dag REORGANIZE_OUTPUT | dot -Tsvg > dag.svg
snakemake --dag REORGANIZE_OUTPUT | dot -Tpng > dag.png
```


## Notes

- Snakemake wants to run with relative dirs for portability.
- Will need some trickery to get timestamped output dirs
- use alias to set default cores?
- WRF very annoying with assumptions about files being present in certain dirs:
    - geogrid output dir *IS* configurable in namelist.wps
    - ungrib output dir *NOT* configurable in namelist.wps
    - metgrid output dir configurable in namelist.wps, but not in namelist.input
    - Vtable must be in workdir for ungrib
    - GEOGRID.TBL and METGRID.TBL can be configured by setting the parent dir XD
    - For real and wrf, namelist + custom files + input from metgrid + output from real must be in same dir, but wrf output can be configured with "history_outname"
- W2W changes files but eventually the output names must be the same as input names --> this introduces loops in the DAG, not good.
- Intermediate and output files depend on settings (e.g. simulated dates),
    - Option 1: use logfiles as output, but then job doesn't rerun if logfile already present
    - Option 2: use logfiles and no output, but outputs are removed if job fails (see https://stackoverflow.com/a/63509711/6012085)
    - Option 3: touch "ungrib.ready" etc. as last command in rule and use that as output.
    - Option 4: write some python functions to parse the namelist and predict the files
- ungrib and metgrid fail with 0 exit status. https://github.com/wrf-model/WPS/issues/252
    - Read the logfile and scan for error
- ungrib doesn't overwrite existing FILE, instead raises "Fortran runtime error: Cannot open file ... file exists."


# TODO's/ideas
- Use snakemake [config](https://snakemake.readthedocs.io/en/stable/snakefiles/configuration.html) for system paths
- Use [peppy](https://snakemake.readthedocs.io/en/stable/snakefiles/configuration.html#configuring-scientific-experiments-via-peps) for executing multiple experiments?
- Want to run with several sets of namelists / geogrid tables / input datasets
- Make W2W conditional: https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#data-dependent-conditional-execution
- Submit final wrf job to slurm
- Auto-generated reports
- Don't use F-strings! In shell blocks, omit the key names in config dict lookups. https://snakemake.readthedocs.io/en/stable/snakefiles/configuration.html#standard-configuration


