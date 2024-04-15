#!/bin/bash
#SBATCH --job-name=compile_wrf        # Job name
#SBATCH --output=log.compile          # Standard output file
#SBATCH --error=log.compile           # Standard error file
#SBATCH --partition=thin              # Partition or queue name
#SBATCH --nodes=1                     # Number of nodes
#SBATCH --ntasks-per-node=4           # Number of tasks per node
#SBATCH --cpus-per-task=1             # Number of CPU cores per task
#SBATCH --time=1:00:00                # Maximum runtime (D-HH:MM:SS)

# For compiling WRF in parallel on a compute node.
# Make sure to run ./configure first and then submit with
#
#     sbatch PK_compile_wrf.sh
#

module load 2023
module load netCDF-Fortran/4.6.1-gompi-2023a  # also loads gcc and gompi
export NETCDF=$(nf-config --prefix)

# make sure configure.wrf is present
./compile -j 4 em_real                 # -j for compiling in parallel (4 processes)
