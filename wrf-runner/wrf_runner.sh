#!/bin/bash
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
module load Python/3.11.3-GCCcore-12.3.0

# Set some paths
export NETCDF=/sw/arch/RHEL8/EB_production/2023/software/netCDF-Fortran/4.6.1-gompi-2023a
export WPS_HOME=$HOME/wrf-model/WPS
export WRF_HOME=$HOME/wrf-model/WRF
export WRF_RUNNER=$HOME/Urban-M4/misc/wrf-runner
export OUTPUT_DIR=$HOME/Urban-M4/experiments
export DATA_HOME=/projects/0/prjs0914/wrf-data/default

# Create venv if it doesn't exist
if test -d $WRF_RUNNER/venv; then
  source venv/bin/activate
else
  python -m venv venv
  source venv/bin/activate
  # For modifying namelists programmatically
  pip install f90nml
  # TODO Install from pypi once branch is merged and released. 
  # Might also not need python script.
  pip install "git+https://github.com/matthiasdemuzere/w2w.git@add_wrf_version"
fi

# Make new run directory
export RUNDIR=$OUTPUT_DIR/$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p $RUNDIR
cd $RUNDIR
echo $PWD
f90nml $WRF_RUNNER/namelist.wps namelist.wps

# Run WPS
f90nml -g geogrid -v opt_geogrid_tbl_path="'$WPS_HOME/geogrid/'" namelist.wps patched_nml && mv patched_nml namelist.wps
f90nml -g metgrid -v opt_metgrid_tbl_path="'$WPS_HOME/metgrid'" namelist.wps patched_nml && mv patched_nml namelist.wps
ln -sf $WPS_HOME/ungrib/Variable_Tables/Vtable.GFS Vtable
ln -sf $WRF_RUNNER/GEOGRID.TBL.ARW $WPS_HOME/geogrid/GEOGRID.TBL  # make sure the right geogrid table is linked.
$WPS_HOME/link_grib.csh "${DATA_HOME}/real-time/gfs-data/*"
$WPS_HOME/geogrid.exe

# Run W2W
w2w $RUNDIR /projects/0/prjs0914/wrf-data/default/lcz/amsterdam_lcz4_clean.tif $RUNDIR/geo_em.d04.nc v4.5.2
python3 $WRF_RUNNER/../fix_w2w_lu_index.py $RUNDIR
mv $RUNDIR/geo_em.d01_61.nc $RUNDIR/geo_em.d01.nc
mv $RUNDIR/geo_em.d02_61.nc $RUNDIR/geo_em.d02.nc
mv $RUNDIR/geo_em.d03_61.nc $RUNDIR/geo_em.d03.nc
mv $RUNDIR/geo_em.d04_LCZ_params.nc $RUNDIR/geo_em.d04.nc

# Continue with WPS
$WPS_HOME/ungrib.exe
$WPS_HOME/metgrid.exe

# Link relevant files for WRF
ln -sf $WRF_HOME/run/CAMtr_volume_mixing_ratio.RCP8.5 CAMtr_volume_mixing_ratio
ln -sf $WRF_HOME/run/ozone* $RUNDIR
ln -sf $WRF_HOME/run/RRTMG* $RUNDIR
ln -sf $WRF_HOME/run/*.TBL $RUNDIR

# Run WRF
f90nml $WRF_RUNNER/namelist.input namelist.input
$WRF_HOME/run/real.exe
$WRF_HOME/run/wrf.exe

# Report status
status=$? && [ $status -eq 0 ] && echo "Run successful"
