import os
import netCDF4 as nc
import numpy as np
import pwd
import sys

datapath = sys.argv[0] # set full datapath

domain = 'd04' # select domain

geo = nc.Dataset(datapath+"/geo_em."+domain+"_LCZ_params.nc","r+") # open the geo_em file

LU_INDEX = geo["LU_INDEX"][:]
LU_INDEX_FIX = np.copy(LU_INDEX)

#
# change in geo files the terrain height
# be careful: the geo_em file is overwritten
#

for iy in range(0,LU_INDEX.shape[1]): # loop over y-direction
  for ix in range(0,LU_INDEX.shape[2]): # loop over x-direction
    if not 1 <= LU_INDEX[:,iy,ix] < 61:
      if 1 <= LU_INDEX[:,iy,ix+1] < 61:
        LU_INDEX_FIX[:,iy,ix] =  LU_INDEX[:,iy,ix+1]
      elif 1 <= LU_INDEX[:,iy,ix-1] < 61:
        LU_INDEX_FIX[:,iy,ix] =  LU_INDEX[:,iy,ix-1]
      elif 1 <= LU_INDEX[:,iy+1,ix] < 61:
        LU_INDEX_FIX[:,iy,ix] =  LU_INDEX[:,iy+1,ix]
      elif 1 <= LU_INDEX[:,iy-1,ix] < 61:
        LU_INDEX_FIX[:,iy,ix] =  LU_INDEX[:,iy-1,ix]
      print('Changed gridcell '+str(iy)+','+str(ix)+' to LU_INDEX = '+str(LU_INDEX_FIX[:,iy,ix]))
      if not 1 <= LU_INDEX_FIX[:,iy,ix] < 61:
        print('Fatal error: None of the four orthogonally adjecent gridcells have been assigned a land-use class. Fix the Python script somehow to look for more grid cells in the vicinity')
        sys.exit(1)
	      	
geo["LU_INDEX"][:] = LU_INDEX_FIX[:]

geo.close()
