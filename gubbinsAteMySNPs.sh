#!/usr/bin/env bash

set -euo pipefail

# Define defaults
indir=""
outdir=""
r1ext="_R1.fastq.gz"
faext=".fasta"
ref=""
env="snps"
threads=4

# Define help page
usage() {
  cat <<EOF
Usage:
  $0 -i DIR -o DIR -R FASTA [-r _R1.EXT -f .fasta -t INT]

Options:
  -i    Input directory (required)
  -o    Output directory (required)
  -r    Read1 file extension (default: _R1.fastq.gz)
  -f    Fasta file extension (default: .fasta)
  -R    Reference file (required)
  -e    Snippy environment name (default: snps)
  -t    Amount of threads to use on intensive tasks (default: 4)
  -h    Show this help
EOF
  exit 0
}

# Read and assign user input
while getopts ":i:o:r:f:R:e:t:h" opt; do
  case "$opt" in
    i) indir="$OPTARG" ;;
    o) outdir="$OPTARG" ;;
    r) r1ext="$OPTARG" ;;
    f) faext="$OPTARG" ;;
    R) ref="$OPTARG" ;;
    e) env="$OPTARG" ;;
    t) threads="$OPTARG" ;;
    h) usage ;;
    # Handle wrong options
    :)
      echo "Option -$OPTARG requires an argument" >&2
      usage
      ;;
    # Handle misinterpretted options
    \?)
      echo "Unknown option: -$OPTARG" >&2
      usage
      ;;
  esac
done

shift $((OPTIND - 1))

# Handle missing mandatory variables
[[ -z "$indir" || -z "$outdir"  || -z "$ref" ]] && {
  echo "Error: -i (indir), -o (outdir), and -R (reference) MUST be specified!" >&2
  usage
}

# Define variables
ref=$(realpath "$ref")
snippy_tsv=input.tsv
snippy_batch=runme.sh
snippy_core=core.full.aln
snippy_clean=clean.full.aln


echo "Creating output directory"
mkdir -p "$outdir"
cd "$outdir"

echo "Removing old snippy tsv files if any"
[[ -f "$snippy_tsv" ]] && rm -f "$snippy_tsv"

# Scan the indir for read1 files
for read1 in $(find "$indir" -iname "*$r1ext"); do

  # Define read2 by replacing "1" in the read 1 file extension with "2"
  r2ext=$(echo "$r1ext" | sed 's/1/2/g')
  read2="${read1/$r1ext/$r2ext}"
  
  # In case read2 file doesn't exist, skip the sample entirely
  [[ ! -f "$read2" ]] && {
    echo "Warning: missing pair for $read1" >&2
    continue
  }
  
  # Define sample from read1 filename but remove file extensions and read1 suffix
  sample=$(basename "$read1" "$r1ext")
  
  # Create input file for snippy
  echo -e "$sample\t$(realpath $read1)\t$(realpath $read2)" >> "$snippy_tsv"
  
done

for fasta in $(find "$indir" -iname "*$faext"); do
  
  # Define sample from filename by removing extension
  sample=$(basename "$fasta" "$faext")

  # Create input file for snippy
  echo -e "$sample\t$(realpath$fasta)" >> "$snippy.tsv"

done

echo "Finished creating snippy input file"

echo "Creating batch snippy call"
micromamba run -n $env snippy-multi "$snippy_tsv" --ref "$ref" --cpus $threads --quiet > "$snippy_batch"

echo "Running snippy batch"
micromamba run -n $env bash "$snippy_batch"

echo "Cleaning alignment for Gubbins"
micromamba run -n $env snippy-clean_full_aln "$snippy_core" > "$snippy_clean"

echo "Running Gubbins"
micromamba run -n $env run_gubbins.py -p gubbins "$snippy_clean" --tree-builder iqtree

cd -

echo "Workflow completed"
