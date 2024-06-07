# Snakemake

```
# Install micromamba on snellius
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
# During install, set conda-forge as default channel
source ~/.bashrc

# Create environment
micromamba create --name snakemake bioconda::snakemake -y
micromamba activate snakemake

# Run snakefile in this dir
snakemake --cores 1
```


## Notes

- Snakemake wants to run with relative dirs for portability.
- Will need some trickery to get timestamped output dirs
- WRF very annoying with assumptions about files being present in certain dirs:
    - geogrid output dir *IS* configurable in namelist.wps
    - ungrib output dir *NOT* configurable in namelist.wps
    - metgrid output dir configurable in namelist.wps, but not in namelist.input
    - Vtable must be in workdir for ungrib
    - GEOGRID.TBL and METGRID.TBL can be configured by setting the parent dir XD
    - For real and wrf, namelist + custom files + input from metgrid + output from real must be in same dir, but wrf output can be configured with "history_outname"
- W2W changes files but eventually the output names must be the same as input names
- Intermediate and output files depend on settings (e.g. simulated dates), need to encode this

