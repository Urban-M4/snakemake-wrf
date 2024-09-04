# Snakemake WRF

A snakemake workflow to run WRF, including pre- and postprocessing.

Multiple experiments are defined in config.yaml:

- USGS: reference
- USGS + WUR parameters: reference setup from summer in the city
- CGLC-MODIS-LCZ: fancy new landuse dataset combining 100m CGLC data with 100m LCZ data
- CGLC-MODIS-LCZ + WUR parameters: same as above but including spatially explicity parameters from WUR
