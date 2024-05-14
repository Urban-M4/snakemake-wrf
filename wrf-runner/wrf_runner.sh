#!/bin/bash
#SBATCH --job-name=wrf_experiment     # Job name
#SBATCH --partition=thin              # Partition or queue name
#SBATCH --nodes=1                     # Number of nodes
#SBATCH --ntasks-per-node=4           # Number of tasks per node
#SBATCH --cpus-per-task=1             # Number of CPU cores per task
#SBATCH --time=1:00:00                # Maximum runtime (D-HH:MM:SS)

# Security; fail on first error; explicit vars only
set -euxo pipefail

# Load dependencies
module load 2023
module load netCDF-Fortran/4.6.1-gompi-2023a  # also loads gcc and gompi
module load Python/3.11.3-GCCcore-12.3.0

# For modifying namelists programmatically
pip install --user f90nml

# Set some paths
export NETCDF=/sw/arch/RHEL8/EB_production/2023/software/netCDF-Fortran/4.6.1-gompi-2023a
export WPS_HOME=$HOME/wrf-model/WPS
export WRF_HOME=$HOME/wrf-model/WRF
export WRF_RUNNER=$HOME/Urban-M4/misc/wrf-runner
export OUTPUT_DIR=$HOME/Urban-M4/experiments
export DATA_HOME=/projects/0/prjs0914/wrf-data/default

# Make new run directory
export RUNDIR=$OUTPUT_DIR/$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p $RUNDIR
cd $RUNDIR
echo $PWD
f90nml $WRF_RUNNER/namelist.wps namelist.wps

# Run WPS
f90nml -g geogrid -v opt_geogrid_tbl_path="'$WPS_HOME/geogrid/'" namelist.wps patched_nml && mv patched_nml namelist.wps
f90nml -g metgrid -v opt_metgrid_tbl_path="'$WPS_HOME/metgrid'" namelist.wps patched_nml && mv patched_nml namelist.wps
ln -s $WPS_HOME/ungrib/Variable_Tables/Vtable.GFS Vtable
$WPS_HOME/link_grib.csh "${DATA_HOME}/real-time/gfs-data/*"
$WPS_HOME/geogrid.exe
$WPS_HOME/ungrib.exe
$WPS_HOME/metgrid.exe

# Run WRF
f90nml $WRF_RUNNER/namelist.input namelist.input
$WRF_HOME/run/real.exe
$WRF_HOME/run/wrf.exe

# Report status
status=$? && [ $status -eq 0 ] && echo "Run successful" || echo "Run failed"
