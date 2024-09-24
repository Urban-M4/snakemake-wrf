import salem

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import wrf


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
        vmin=None,
        vmax=None,
        cmap=None,
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
