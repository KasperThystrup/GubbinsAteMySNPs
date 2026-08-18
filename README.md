# GubbinsAteMySNPs
## Requirements
* Micromamba installed
* A conda/mamba environment with Snippy and Gubbins installed

## Usage
GubbinsAteMySNPs screens the input directory (`-i`) recursively for paired end read files with the provided mate and file extension (`-r` Default: _R1.fastq.gz) as well as screens for assembly files with the provided file extension (`-f` Default: .fasta). The output directory are populated with all intermediate files by the tools and final results files. Micromamba runs the commands directly by prompting the required mamba environment without activating it first. Thus, its important to provide íts correct name (`-e` Default: snps). 

```
Usage:
  ./gubbinsAteMySNPs.sh -i DIR -o DIR -R FASTA [-r _R1.EXT -f .fasta -t INT]

Options:
  -i    Input directory (required)
  -o    Output directory (required)
  -r    Read1 file extension (default: _R1.fastq.gz)
  -f    Fasta file extension (default: .fasta)
  -R    Reference file (required)
  -e    Snippy and Gubbins environment name (default: snps)
  -t    Amount of threads to use on intensive tasks (default: 4)
  -h    Show this help
```
## Installation
Install the required environment
```
micromamba create -n snps bioconda::snippy bioconda::gubbins --yes
```
Navigate to you folder with repositories (e.g. `~/repos/`), clone the repository, and navigate into the cloned folder
```
cd ~/repos
git clone https://github.com/KasperThystrup/GubbinsAteMySNPs.git
cd GubbinsAteMySNPs
```

Attempt to evoke the help page, to ensure everything works
```
bash gubbinsAteMySNPs.sh -h
```


