rule analyse_output:
    input:
        collect("{experiment}/finished.wrf", experiment=config["experiments"].keys())
    log:
        # path to the processed notebook
        notebook="logs/notebooks/analyse_output.ipynb"
    notebook:
        "notebooks/analyse_output.ipynb"
