# WRF Runner

* Run a complete WPS/WRF experiment in one go
* Make a dedicated directory for each experiment
* The original WRF source code is untouched
* Namelists under version control so you can always go back

## How to use

It assumes you have a compiled WRF and WPS with the following folder structure

  * $HOME/wrf-model/WPS  # compiled clone of https://github.com/wrf-model/WRF
  * $HOME/wrf-model/WRF  # compiled clone of https://github.com/wrf-model/WPS
  * $HOME/Urban-M4/misc/wrf-runner  # clone of https://github.com/Urban-M4/misc
  * $HOME/Urban-M4/experiments  # destination for input/output of each experiment

Make sure the paths are set up correctly on your system and match with the paths
in `wrf_runner.sh`. Modify (and commit) the namelists as seen fit, then call the
runner:

```bash
# Run interactive job
bash wrf_runner.sh

# Or submit as batch job to slurm queue
sbatch wrf_runner.sh
```

This will create a new folder in `$HOME/Urban-M4/experiments/<timestamp>` where
all output and intermediate files are stored, and run all steps for WPS and WRF.

## Notes

[f90nml](https://f90nml.readthedocs.io/en/latest/) is used to format and modify
namelists from the command line. Beware that:

  * paths must be in "'double quotes'" (see https://github.com/marshallward/f90nml/issues/126)
  * cannot update in place


## To do

* Use MODIS_LCZ landuse with wudapt-to-wrf
* Use the "standard" heatwave case for amsterdam
* Use IFS analysis for initial/boundary conditions
* Use custom WUR landuse from summer in the city (checkout different branch of WRF?)
* Use custom river temperatures from rijkswaterstaat(?)
* Enable additional custom landuse for building albedo/emissivity
* Add some default plots of input/output for quick inspection of results
