from pathlib import Path

import f90nml


rule UPDATE_NAMELIST_WRF:
    input:
        Path(workflow.workdir_init) / "resources" / "namelist.input",
    output:
        "{experiment}/namelist.input",
    run:
        num_land_cat = config["experiments"][wildcards.experiment]["num_land_cat"]
        use_wudapt_lcz = config["experiments"][wildcards.experiment]["use_wudapt_lcz"]

        nml_input = f90nml.read(input)
        nml_input["physics"]["num_land_cat"] = num_land_cat
        nml_input["physics"]["use_wudapt_lcz"] = 1 if use_wudapt_lcz else 0

        namelist_path = Path(wildcards.experiment, "namelist.input")
        nml_input.write(namelist_path)


rule REAL:
    input:
        "{experiment}/namelist.input",
        "{experiment}/finished.metgrid",
    output:
        "{experiment}/finished.real",
    shell:
        """
        cd {wildcards.experiment}
        {config[wrf_home]}/run/real.exe
        touch finished.real
        """


rule WRF:
    input:
        "{experiment}/namelist.input",
        "{experiment}/finished.real",
        wrf_job=Path(workflow.workdir_init) / "resources" / "wrf.job",
    output:
        "{experiment}/finished.wrf",
    shell:
        """
        cd {wildcards.experiment}
        cp {input.wrf_job} .


        # TODO link instead of cp and unlink after finishing?
        cp -f {config[wrf_home]}/run/CAMtr_volume_mixing_ratio.RCP8.5 CAMtr_volume_mixing_ratio
        cp -f {config[wrf_home]}/run/ozone* .
        cp -f {config[wrf_home]}/run/RRTMG* .
        cp -f {config[wrf_home]}/run/*.TBL .

        # Submit wrf job to SLURM and wait for it to finish
        sbatch --wait wrf.job {config[wrf_home]}/run/wrf.exe

        # Report status
        touch finished.wrf
        """
