import salem

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import wrf
import numpy as np
from matplotlib.colors import BoundaryNorm
from matplotlib.colors import LinearSegmentedColormap


def get_extent(variable):
    return [
        variable.lon.min(),
        variable.lon.max(),
        variable.lat.min(),
        variable.lat.max(),
    ]


def add_subplot(fig, i, j, k, title):
    """Add a subplot to a figure with UrbanM4 style."""
    AX_OPTIONS = {
        "color": "black",
        "linestyle": "dotted",
        "linewidth": 0.5,
        "zorder": 103,
        "draw_labels": True,
        "x_inline": False,
        "y_inline": False,
    }
    TITLE_OPTIONS = {
        "loc": "left",
        "fontsize": "x-large",
        "fontweight": "bold",
    }

    ax = fig.add_subplot(i, j, k, projection=ccrs.PlateCarree())

    gl = ax.gridlines(**AX_OPTIONS)
    gl.right_labels = False
    gl.top_labels = False
    ax.coastlines(linewidth=1.0, resolution="10m")
    ax.set_title(title, **TITLE_OPTIONS)

    return ax


def plot_colormesh(fig, ax, variable, unit, **kwargs):
    """Add a colormesh on top of a figure with UrbanM4 style."""

    cm_options = dict(
        transform=ccrs.PlateCarree(),
    ).update(kwargs)

    colormesh = ax.pcolormesh(
        variable.lon,
        variable.lat,
        variable,
        **cm_options,
    )
    fig.colorbar(
        colormesh,
        orientation="horizontal",
        fraction=0.09,
        pad=0.1,
        label=unit,
        ax=ax,
    )


def side_by_side_plot(variables, titles, unit, **kwargs):
    """Plot two colormesh figures side by side."""
    fig = plt.figure(figsize=(15, 5))

    for i, (variable, title) in enumerate(zip(variables, titles)):
        ax = add_subplot(fig, 1, 2, i, title)
        ax.set_extent(get_extent(variable))
        plot_colormesh(fig, ax, variable, unit, **kwargs)

    return fig


def plot_difference(variables, titles, unit, **kwargs):
    """Plot the difference between two fields as a colormesh."""
    assert len(variables) == 2, "Length of `variables` should equal 2"
    assert len(variables) == 2, "Length of `titles` should equal 2"

    diff = variables[1] - variables[0]
    title = f"{titles[1]} - {titles[0]}"

    fig = plt.figure(figsize=(15, 5))
    ax = add_subplot(1, 1, 1, title)
    ax.set_extent(get_extent(diff))

    plot_colormesh(fig, ax, diff, unit, **kwargs)

    return fig


# Open file
def calc_q(RH, T2M):
    """Calculate specific humidity (q) in g/kg."""
    p = 101300
    t2 = T2M - 273.13
    exponent = 7.5 * t2 / (t2 - 237.3)  #
    e = (RH / 100) * 610.7 * 10**exponent
    q = ((0.622 * e) / p) * 1000
    return q


def get_wrfout_var(filename, variable, itime):
    return salem.open_wrf_dataset(filename)[variable].isel(itime)


def get_wrfout_uhi(filename, itime, landuse):
    """Get temperature as offset from rural reference."""
    lu_index = salem.open_wrf_dataset(filename)["LU_INDEX"].isel(itime)
    t2 = salem.open_wrf_dataset(filename)["T2"].isel(itime)

    # TODO: can we get rid of the dims?
    dims = ("west_east", "south_north")

    if landuse == "MODIS":
        rural_reference = t2.where(lu_index < 51).mean(dims)
    elif landuse == "USGS":
        rural_reference = t2.where(lu_index != 1).mean(dims)
    else:
        raise ValueError(f"Unknown landuse {landuse}")

    return t2 - rural_reference


def get_wrfout_q(filename, itime):
    """Read the relevant variables from wrfout file and calculate q."""
    ds = salem.open_wrf_dataset(filename)

    q2 = ds["Q2"].isel(time=itime)
    t2 = ds["T2"].isel(time=itime)
    psfc = ds["PSFC"].isel(time=itime)

    rh = wrf.rh(q2, psfc, t2)
    return calc_q(rh, t2)


def generate_cmap_for_landuse(landuse_name):
    if landuse_name == "MODIS":
        colors = [
            [0.43, 0.89, 1.0],
            [0.67, 0.94, 1.0],
            [1.0, 0.77, 0.89],
            [1.0, 0.6, 0.8],
            [1.0, 0.0, 1.0],
            [0.50, 0.0, 0.50],
            [0.0, 0.0, 0.50],
            [0.27, 0.27, 1.0],
            [0.2, 0.4, 1.0],
            [0.52, 0.64, 1.0],
            [1.0, 1.0, 1.0],  # URBAN IN ORIGINAL FILE
            [0.8, 0.8, 0.8],
            [0.70, 0.70, 0.70],
            [0.0, 0.0, 0.0],
            [0.6, 0.6, 0.6],
            [0.35, 0.35, 0.35],
            [0.50, 0.50, 0.0],
            [0.0, 0.36, 0.0],
            [0.0, 0.50, 0.0],
            [0.2, 0.6, 0.4],
            [0.62, 0.84, 0.0],
            # TODO add 20 more grays
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.70, 0.70, 0.70],
            [0.83, 1.0, 0.35],
            [1.0, 1.0, 0.0],
            [1.0, 0.72, 0.44],
            [1.0, 0.6, 0.0],
            [1.0, 0.4, 0.0],
            [1.0, 0.0, 0.0],
            [0.64, 0.44, 1.0],
            [0.74, 0.29, 0.0],
            [0.67, 0.0, 0.22],
            [0.52, 0.0, 0.0],
        ]
    elif landuse_name == "USGS":
        colors = np.array(
            [
                [1, 0, 0],  #  1 Urban and Built-up Land
                [1, 1, 0],  #! 2 Dryland Cropland and Pasture
                [1, 1, 0.2],  #  3 Irrigated Cropland and Pasture
                [1, 1, 0.3],  #  4 Mixed Dryland/Irrigated Cropland and Pasture
                [0.7, 0.9, 0.3],  #  5 Cropland/Grassland Mosaic
                [0.7, 0.9, 0.3],  #  6 Cropland/Woodland Mosaic
                [0, 1, 0],  #  7 Grassland
                [0.3, 0.7, 0],  #  8 Shrubland
                [0.82, 0.41, 0.12],  #  9 Mixed Shrubland/Grassland
                [1, 0.84, 0.0],  #  10 Savanna
                [0.2, 0.8, 0.4],  #  11 Deciduous Broadleaf Forest
                [0.2, 0.8, 0.2],  #  12 Deciduous Needleleaf Forest
                [0, 0.4, 0.2],  #  13 Evergreen Broadleaf Forest
                [0, 0.4, 0],  #! 14 Evergreen Needleleaf Forest
                [0.2, 0.6, 0.2],  #  15 Mixed Forests
                [0, 0, 0.88],  #  16 Water Bodies
                [0, 1, 1],  #! 17 Herbaceous Wetlands
                [0.2, 1, 1],  #  18 Wooden Wetlands
                [0.914, 0.914, 0.7],  #  19 Barren or Sparsely Vegetated
                [0.86, 0.08, 0.23],  #  20 Herbaceous Tundraa
                [0.86, 0.08, 0.23],  #  21 Wooded Tundra
                [0.97, 0.5, 0.31],  #! 22 Mixed Tundra
                [0.91, 0.59, 0.48],  #! 23 Barren Tundra
                [1, 1, 1],  #! 24 Snow and Ice
            ]
        )

    nlevs = len(colors)
    cmap = LinearSegmentedColormap.from_list("luse", colors, N=nlevs)
    levels = np.arange(nlevs)
    norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
    return cmap, norm
