# Different input dataset options

"Default"

## Summer in the city
- USGS default: usgs_30s + GEOGRID.ARW
- SITC setup: usgs_30s + wur-landuse + GEOGRID.ARW SITC version  (rename that to GEOGRID.WUR or GEOGRID.SITC?)

## W2W baseline
- MODIS default: modis_30s + GEOGRID.ARW
- MODIS_LCZ: cglc_modis_lcz + GEOGRID.LCZ
    - No W2W refinement
    - W2W Global 100m (is that the same as no W2W?)
    - W2W Amsterdam from students (more detail for Amsterdam?)


Beware of fallback to "default"! Also see how that affects things.
