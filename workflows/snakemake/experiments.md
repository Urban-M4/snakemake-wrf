# Different input dataset options
These are the experiments set up in `workflows/snakemake/config.yaml`

"Default"

## USGS standard
- USGS default: usgs_30s + GEOGRID.TBL.ARW_USGS
    - Standard resolution USGS dataset with 24 categories

## CGLC-MODIS-LCZ standard
- MODIS_LCZ: cglc_modis_lcz + GEOGRID.TBL.ARW_LCZ
    - Uses standard global cglc_modis_lcz 100 m dataset, where building height etc is determined by category

## Summer in the city (WUR)
- usgs_30s + wur-landuse + GEOGRID.TBL.ARW_WUR
    - USGS dataset with 100 m resolution data from Summer in the City (SITC) for 2 inner domains

## CGLC-MODIS-LCZ + WUR parameters
- MODIS_LCZ: cglc_modis_lcz + GEOGRID.TBL.ARW_LCZ_WUR 
    - Uses cglc_modis_lcz w/ SITC parameters (e.g. building height)

Beware of fallback to "default"! Also see how that affects things.
