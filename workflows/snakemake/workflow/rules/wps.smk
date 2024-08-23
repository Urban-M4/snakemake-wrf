from pathlib import Path

import f90nml

rule UPDATE_NAMELIST_WPS:
    input:
        namelist_wps = workflow.source_path("../../resources/namelist.wps")
    output:
        "{experiment}/namelist.wps",
    run:
        # Get parameters from config
        geog_data_res = config['experiments'][wildcards.experiment]['geog_data_res']
        geog_data_path = config['experiments'][wildcards.experiment]['geog_data_path']

        # Read source namelist.wps with f90nml, make some changes, and save in experiment dir
        nml = f90nml.read(input.namelist_wps)
        nml["geogrid"]["geog_data_path"] = geog_data_path
        nml["geogrid"]["geog_data_res"] = geog_data_res
        nml.write(f"{wildcards.experiment}/namelist.wps")

rule GEOGRID:
    input: "{experiment}/namelist.wps",
    output: "{experiment}/finished.geogrid"
    params: geogrid_table = lambda wildcards: workflow.source_path(config['experiments'][wildcards.experiment]['geogrid_table']),
    shell:
        """
        cd {wildcards.experiment}
        mkdir -p geogrid
        cp {params.geogrid_table} GEOGRID.TBL

        # Run geogrid
        {config[wps_home]}/geogrid.exe

        # Scan logfile for errors and raise if necessary (geogrid can fail silently with 0 exit status)
        grep "ERROR" geogrid.log && echo "Aborting: ERROR in geogrid.log." && exit 1

        touch finished.geogrid
        """

rule UNGRIB:
    input: "{experiment}/namelist.wps"
    output: "{experiment}/finished.ungrib"
    shell:
        """
        cd {wildcards.experiment}

        # Remove old output if present (ungrib doesn't like to overwrite stuff)
        rm -f FILE*

        # Link vtable
        cp {config[wps_home]}/ungrib/Variable_Tables/Vtable.ECMWF Vtable

        # Link gribfiles
        {config[wps_home]}/link_grib.csh {config[data_home]}/real-time/july2019/*

        # Run ungrib
        {config[wps_home]}/ungrib.exe

        # Scan logfile for errors and raise if necessary (ungrib can fail silently with 0 exit status)
        grep "ERROR" ungrib.log && echo "Aborting: ERROR in ungrib.log." && exit 1

        # Report ready
        touch finished.ungrib
         """

rule METGRID:
    input:
        "{experiment}/namelist.wps",
        "{experiment}/finished.ungrib",
        "{experiment}/finished.geogrid",
    output: "{experiment}/finished.metgrid"
    shell:
        """
        cd {wildcards.experiment}
        mkdir -p metgrid

        cp {config[wps_home]}/metgrid/METGRID.TBL.ARW METGRID.TBL
        {config[wps_home]}/metgrid.exe

        # Scan logfile for errors and raise if necessary (metgrid can fail silently with 0 exit status)
        grep "ERROR" metgrid.log && echo "Aborting: ERROR in metgrid.log. " && exit 1

        touch finished.metgrid
        """
