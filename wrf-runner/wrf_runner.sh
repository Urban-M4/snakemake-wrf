#!/bin/bash
#
# Script to prep input for wrf and perhaps also run wrf itself
# though you probably want to configure another jobscript for that.
#
# Nice way to use it is, e.g.:
#   srun -p staging -n 1 -t 01:00:00 --pty bash wrf_runner.sh WUR
#
#SBATCH --job-name=wrf_experiment     # Job name
#SBATCH --partition=thin              # Partition or queue name
#SBATCH --nodes=1                     # Number of nodes
#SBATCH --ntasks-per-node=4           # Number of tasks per node
#SBATCH --cpus-per-task=1             # Number of CPU cores per task
#SBATCH --time=8:00:00                # Maximum runtime (D-HH:MM:SS)

# Security; fail on first error; explicit vars only
set -euxo pipefail

# Load dependencies
module load 2023
module load netCDF-Fortran/4.6.1-gompi-2023a  # also loads gcc and gompi
export NETCDF=$(nf-config --prefix)

# Set some paths
export NETCDF=/sw/arch/RHEL8/EB_production/2023/software/netCDF-Fortran/4.6.1-gompi-2023a
export WPS_HOME=$HOME/wrf-model/WPS
export WRF_HOME=$HOME/wrf-model/WRF
export OUTPUT_DIR=$HOME/Urban-M4/experiments
export DATA_HOME=/projects/0/prjs0914/wrf-data/default

# Define experiment name; set here or pass in through command line
# Options: USGS, MODIS_LCZ, WUR, WUR_LCZ
EXP=USGS
EXP="${1:-USGS}"

# Make new experiment directory
export RUNDIR=wrf_experiments/${EXP}
mkdir -p $RUNDIR
mkdir -p $RUNDIR/geogrid
mkdir -p $RUNDIR/metgrid

# Copy experiment-dependent files
cp namelist.wps_$EXP $RUNDIR/namelist.wps
cp namelist.input_$EXP $RUNDIR/namelist.input
cp GEOGRID.TBL.ARW_$EXP $RUNDIR/GEOGRID.TBL

# Copy additional input files from WRF/WPS
cd $RUNDIR
cp $WPS_HOME/metgrid/METGRID.TBL.ARW METGRID.TBL
cp $WPS_HOME/ungrib/Variable_Tables/Vtable.ECMWF Vtable
cp $WRF_HOME/run/CAMtr_volume_mixing_ratio.RCP8.5 CAMtr_volume_mixing_ratio
cp $WRF_HOME/run/ozone* .
cp $WRF_HOME/run/RRTMG* .
cp $WRF_HOME/run/*.TBL .

# Run experiments
$WPS_HOME/link_grib.csh "${DATA_HOME}/real-time/july2019/*"
$WPS_HOME/ungrib.exe
$WPS_HOME/geogrid.exe
grep "ERROR" geogrid.log && echo "Aborting: ERROR in geogrid.log." && exit 1
$WPS_HOME/metgrid.exe
grep "ERROR" metgrid.log && echo "Aborting: ERROR in metgrid.log." && exit 1

$WRF_HOME/run/real.exe

# Configure OpenMP thread affinity
# export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
# export OMP_PLACES=cores
# export OMP_PROC_BIND=close
# srun $WRF_HOME/run/wrf.exe
