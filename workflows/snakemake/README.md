# Snakemake

```
# Install micromamba on snellius
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
# During install, set conda-forge as default channel
source ~/.bashrc

# Create environment
micromamba create --name snakemake bioconda::snakemake -y
micromamba activate snakemake
```


