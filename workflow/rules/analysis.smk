rule analyse_output:
    log:
        # path to the processed notebook
        notebook="logs/notebooks/analyse_output.ipynb"
    notebook:
        "notebooks/analyse_output.ipynb"
