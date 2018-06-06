# Whole Genome Duplication Analysis Scripts
These scripts attempt to determine whether or not there is any support for a shared whole genome duplication between two taxa based on their transcriptomes.

## Dependencies
1. [TransDecoder](http://sourceforge.net/projects/transdecoder/files/OLDER/TransDecoder_r20140704.tar.gz/download)
	* Used to determine likely open reading frames in a given transcriptome and its corresponding protein translation.
2. [Blat](http://hgdownload.cse.ucsc.edu/admin/exe/)
	* Used to determine likely paralogs.
3. [KaKs_Calculator](https://code.google.com/p/kaks-calculator/downloads/list)
	* Used to estimate the number of synonymous substitions per synonymous site (Ks) between paralogs.
4. [ProteinOrtho.pl](https://www.bioinf.uni-leipzig.de/Software/proteinortho/)
	* Used to identify orthologous sequences shared across the given transcriptomes.
5. [Blastp](http://1.usa.gov/1zTP2u6)
	* Used by ProteinOrtho.pl to detect orthologs. Also used to reduce orthologous sequences to only their shared homologous sites.
6. [MUSCLE](http://www.drive5.com/muscle/downloads.htm)
	* Used to align orthologous family sequences after reduction to homologous sites.
6. [RAxML](https://github.com/stamatak/standard-RAxML)
	* Used to calculate best tree for a quartet as well as its support.
7. [R](http://cran.r-project.org/mirrors.html)
	* Plotting and statistics software used to generate the actual Ks plot.

# wgd-test.pl
## Script Workflow

Transcriptomes given to the script are first translated into their most likely protein using TransDecoder.
An intraspecies all-versus-all blat search is then performed for each input transcriptome
in order to identify homologous protein pairs.
Ks is then calculated for each protein pair using KaKs_Calculator.
Pairs are then filtered to the Ks range specified by the user,
and to have a minimum alignment length of 300bp (by default).
In each transcriptome and from each pair found in the specified Ks range, 1 of the 2 sequences is chosen
as a representative (the query sequence is chosen; this choice is somewhat arbitrary).
For each transcriptome, the representative sequences (1 per pair) are combined into a single fasta file.
Quartets are then identified by running ProteinOrtho on the files of pair representatives:
assuming an input of 2 transcriptomes,
each quartet corresponds to a 1-to-1 cluster, containing exactly 1 representative sequence from each transcriptome.
For each quartet, alignments are restricted to homologous sites only using blastp,
homologous sites are then aligned using MUSCLE.
If the final protein alignment meets the required length cutoff (100 amino acids/300 nucleotides by default),
the sequence is reverse translated to its original nucleotide sequence.
RAxML is then used to run a 100-replicate rapid bootstrap using the GTR-Gamma model.
If the support of the quartet split is high enough (>= 70 by default),
this quartet's topology is used as evidence for whether or not the given transcriptomes shared a whole genome duplication.


## Script Usage & Settings
### Usage
At the mininmum, the script requires two FASTA files specfied with -t or --transcriptomes to run, the desired Ks range over which to check for a shared WGD must also specified for each transcriptome using -k or --ks:

```
wgd-test.pl -t transcriptome1.fa transcriptome2.fa -k 0.2-0.6,0.3-0.7 
```

If only one Ks range is given as in the following invocation, this range is used for both transcriptomes:

```
wgd-test.pl -t transcriptome1.fa transcriptome2.fa -k 0.2-0.6
```

### Command Line Options
For further fine-tuning of the script, the following options can also be specified:

| Option Flag(s)             | Option Descripton                                                                                     | Default |
|:---------------------------|:-----------------------------------------------------------------------------------------------------:|:-------:|
| -k, --ks                   |range of Ks to search for each transcriptome                                                           | none |
| -t, --transcriptomes       |file names of at least two transcriptomes (in FASTA format) to use for analyses                        | none |
| -m, --model                |model used by KaKs_Calculator to determine Ks                                                          | YN |
| -o, --output               |name of the directory to store output files in                                                         | "wgd-test-" + Unix time of script invocation) |
| -l, --min-length           |the minimum alignment length of paralogous sequences                                                   | 300 nucleotides |
| -p, --pid-cut              |minimum pairwise percent identity allowed between two members of a quartet                             | 80% |
| -b, --boot-cut             |minimum RAxML bootstrap support required to use a quartet                                              | 70 |
| --pfam-cpus                |the number of CPUs to let hmmscan using during pfam analysis                                           | current number of free CPUs |
| --pfam-search              |full path to pfam binary for usage in pfam search                                                      | none |
| -T, --n-threads            |the number of families to analyze concurrently                                                         | current number of free CPUs |
| -h, --help                 |display help and exit                                                                                  | N/A |

## Output Files
The following files can be found in the output directory upon successful completion of the script given that the user invoked the script with the following command:

```
wgd-test.pl -t trans1.fasta trans2.fasta -k 0.2-0.6
```

* The two most important output files, each containing a list of well-supported quartets
	* **wgd-support.txt**: file containing a list of quartets which support a shared WGD
	* **wgd.against.txt**: file containing a list of quartets which are against a shared WGD
* **genes/**: directory containing quartet alignments (**-aligned.nex** files) and corresponding RAxML output files for genes which met all thresholds required for analysis
* Note: there would be a corresponding **trans2** prefix for each of these output files
* TransDecoder output for each input transcriptome:
	* **trans1.fasta.transdecoder.bed**: bed output from TransDecoder
	* **trans1.fasta.transdecoder.cds**: corresponding CDS of putative peptides identified
	* **trans1.fasta.transdecoder.gff3**: gff3 output from TransDecoder
	* **trans1.fasta.transdecoder.mRNA**: corresponding mRNA of putative peptides identified
	* **trans1.fasta.transdecoder.pep**: putative peptides identified
* **trans1.fasta.transdecoder.pep.pslx**: blat output from trans1.fasta's all versus all self blat
* **trans1.atx**: atx formatted file containing homologous protein pairs used as KaKs_Calculator's input
* **trans1.YN.kaks**: KaKs_Calculator output (YN would be whichever model name you specified)
* **trans1.fasta.YN.ks_0.2-0.6**: FASTA file containing one sequence from each protein pair with a Ks between whatever range the user specified (YN would be whichever model name you specified, 0.2-0.6 will vary based on user specified Ks range)
* **wgd-test.proteinortho**: output by ProteinOrtho, contains final sequence clustering information of input files. This the file parsed by the toca.pl to determine clustering
* **wgd-test.blast-graph**: output by ProteinOrtho, contains similarity scores between contigs as determined by blastp
* **wgd-test.proteinortho-graph**: output by ProteinOrtho, contains similarity scores between contigs as determined by blastp

# wgd-plot.pl and wgd-plot.r
## Script Workflow
Transcriptomes given to the script are first translated into their most likely protein using TransDecoder. An intraspecies all versus all blat search is then performed for for each input transcriptome in order to identify homologous protein pairs. Ks is then calculated for each protein pair using KaKs_Calculator. Pairs are **NOT** filtered to a specific Ks range. Quartets are then identified by taking one sequence from each pair found in each transcriptome and running ProteinOrtho. Alignments are restricted to homologous sites only using blastp, homologous sites are then aligned using MUSCLE. If the final protein alignment meets the required length cutoff (100 amino acids/300 nucleotides), the sequence is reverse translated to its original nucleotide sequence. RAxML is then used to run a 100 replicate rapid bootstrap using the GTR-Gamma model. If the support of the quartet split is high enough (>= 70 by default), this quartet's topology is used as evidence for whether or not the given transcriptomes shared a whole genome duplication.

## Script Usage & Settings
### Usage
At the mininmum, the script requires two FASTA files specfied with -t or --transcriptomes to run:

```
wgd-plot.pl -t transcriptome1.fa transcriptome2.fa
```

After successful completion of the script, the files **transcriptome1.csv** and **transcriptome2.csv** would be located in the output directory. A sliding window plot can be generated for a particular csv file by running the following command:

```
wgd-plot.r transcriptome1.csv
```

### Command Line Options
For further fine-tuning of the script, the following options can also be specified:

| Option Flag(s)             | Option Descripton                                                                                     | Default |
|:---------------------------|:-----------------------------------------------------------------------------------------------------:|:-------:|
| -t, --transcriptomes       |file names of at least two transcriptomes (in FASTA format) to use for analyses                        | none |
| -m, --model                |model used by KaKs_Calculator to determine Ks                                                          | YN |
| -o, --output               |name of the directory to store output files in                                                         | "wgd-plot-" + Unix time of script invocation) |
| -l, --min-length           |the minimum alignment length of paralogous sequences                                                   | 300 nucleotides |
| -p, --pid-cut              |minimum pairwise percent identity allowed between two members of a quartet                             | 80% |
| -b, --boot-cut             |minimum RAxML bootstrap support required to use a quartet                                              | 70 |
| --pfam-cpus                |the number of CPUs to let hmmscan using during pfam analysis                                           | current number of free CPUs |
| --pfam-search              |full path to pfam binary for usage in pfam search                                                      | none |
| -T, --n-threads            |the number of families to analyze concurrently                                                         | current number of free CPUs |
| -h, --help                 |display help and exit                                                                                  | N/A |

## Output Files
The following files can be found in the output directory upon successful completion of the script given that the user invoked the script with the following command:

```
wgd-plot.pl -t trans1.fasta trans2.fasta
```

* The two most important output files which are used to generate the plot. Each line corresponds to a single quartet, the first value is the Ks of the protein pair from the species's perspective, and the second value is boolean indicating whether or not the quartet supports a WGD (0 for against, 1 for support). These files are used as the input for wgd-plot.r:
	* **trans1.csv**: file containing a list of quartets which support a shared WGD
	* **trans2.csv**: file containing a list of quartets which are against a shared WGD
	* Using the above files as input for wgd-plot.r would create **trans1.pdf** and **trans2.pdf**
* **genes/**: directory containing quartet alignments (**-aligned.nex** files) and corresponding RAxML output files for genes which met all thresholds required for analysis
* Note: there would be a corresponding **trans2** prefix for each of these output files
* TransDecoder output for each input transcriptome:
	* **trans1.fasta.transdecoder.bed**: bed output from TransDecoder
	* **trans1.fasta.transdecoder.cds**: corresponding CDS of putative peptides identified
	* **trans1.fasta.transdecoder.gff3**: gff3 output from TransDecoder
	* **trans1.fasta.transdecoder.mRNA**: corresponding mRNA of putative peptides identified
	* **trans1.fasta.transdecoder.pep**: putative peptides identified
* **trans1.fasta.transdecoder.pep.pslx**: blat output from trans1.fasta's all versus all self blat
* **trans1.atx**: atx formatted file containing homologous protein pairs used as KaKs_Calculator's input
* **trans1.YN.kaks**: KaKs_Calculator output (YN would be whichever model name you specified)
* **trans1.fasta.YN.ks_0.2-0.6**: FASTA file containing one sequence from each protein pair with a Ks between whatever range the user specified (YN would be whichever model name you specified, 0.2-0.6 will vary based on user specified Ks range)
* **wgd-plot.proteinortho**: output by ProteinOrtho, contains final sequence clustering information of input files. This the file parsed by the toca.pl to determine clustering
* **wgd-plot.blast-graph**: output by ProteinOrtho, contains similarity scores between contigs as determined by blastp
* **wgd-plot.proteinortho-graph**: output by ProteinOrtho, contains similarity scores between contigs as determined by blastp

