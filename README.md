Usage:
  ./gubbinsAteMySNPs.sh -i DIR -o DIR -R FASTA [-r _R1.EXT -f .fasta -t INT]

Options:
  -i    Input directory (required)
  -o    Output directory (required)
  -r    Read1 file extension (default: _R1.fastq.gz)
  -f    Fasta file extension (default: .fasta)
  -R    Reference file (required)
  -e    Snippy environment name (default: snps)
  -t    Amount of threads to use on intensive tasks (default: 4)
  -h    Show this help
