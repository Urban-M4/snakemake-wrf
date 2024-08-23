# Steps to compile WRF on Snellius

module load 2023
module avail netcdf
module load netCDF-Fortran/4.6.1-gompi-2023a  # also loads gcc and gompi

export NETCDF=$(nf-config --prefix)

git clone https://github.com/wrf-model/WRF.git  # or git@github.com:wrf-model/WRF.git if you have setup SSH keys
git clone https://github.com/wrf-model/WPS.git  # or git@github.com:wrf-model/WPS.git if you have setup SSH keys

cd WRF
./configure  # choose 34 (gcc dmpar) and 1 (simple nesting)
./compile em_real >& log.compile &
# sbatch PK_compile_wrf.slurm  # alternative for (parallel) compile on compute node
tail -f log.compile

cd ../WPS
./configure --build-grib2-libs  # Choose option 1 (serial); this automatically builds jasper, zlib and libpng (old versions, since WPS is not keeping up)
./compile &> log.compile &
tail -f log.compile

## Note
# For WRF compiled with SMPAR + DMPAR, WPS doesn't compile geogrid and metgrid
# See report and fix in https://github.com/wrf-model/WPS/issues/110 (add `-fopenmp`)



# Compiling with new cmake workflow
./configure_new -p GNU -x -- -DUSE_MPI=ON -DUSE_OPENMP=ON -DWRF_NESTING=BASIC
srun -p staging -n 8 -t 01:00:00 --pty ./compile_new -j 8
