# fastq-utils
Utilities for general batch-processing of fastq files.

These utilites are general shell scripts for processing multiple fastq files. 
They are typically linked to specific versions of open-source bioinformatics software,
in order to enhance reproducibility. Updates to this repository include updates to 
the scripts, and updates to the software versions on which they depend.

All scripts support provide help via a `-h` or, equivalently, `--help` option. 

---

copy_fastqs.sh
==============

Simple utility to copy fastq files from paired-end runs from one or more 
Illumina-style output folders to a target folder. This is
helpful in the case where fastq files from multiple runs or projects will be analyzed as
part of the same analysis. 

Assumptions:
------------

1. Each source folder contains a collection of sample folders whose names are of the form `Sample_samp-name`, where `samp-name` is the sample name.
2. All sample names are unique across all source folders.
3. Each sample folder contains matching pairs of "read 1" and "read 2" fastq.gz files, with the "read 1" file names containing the string `_R1` and the "read 2" files being identical except that `_R1` is replaced by `_R2`. Note this means that the sample name must not contain the string `_R1` or `_R2`, or begin with the string `R1` or `R2`.
 
Requirements:
-------------

None.

Syntax:
-------

    copy_fastqs.sh destination_dir project_dir1 [project_dir2 [project_dir3 ...]]

Notes:
------

Each copy is performed in the background. For a very large number of files, you must be able to open a sufficient number of file handles.

---

generate_qcs.sh
===============

Utility to generate quality control files for multiple fastq files, using [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) version 0.11.3.

Assumptions:
------------

`source_dir` contains a collection of `fastq.gz` files.

Requirements:
-------------

1. [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) version 0.11.3.
2. [Java Development Kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html) version 1.8.0_74


Syntax:
-------

    generate_qcs.sh [options] source_dir output_dir
    
Notes:
------

Runs as a single process. Use the `-t` (`--threads`) option to specify the number of files that can be simultaneously processed.

---

align_mRNA.sh
=============

Aligns paired-end reads of mRNA samples stored in fastq.gz files, producing bam files as output, using [HISAT2](https://ccb.jhu.edu/software/hisat2/index.shtml) version 2.0.3-beta.

Assumptions:
------------

1. `source_dir` contains a collection of pairs of fastq.gz files, with samples represented by a "read 1" and "read 2" files. "Read 1" files end with `_R1.fastq.gz` and the matching "read 2" file is identical except that it ends `_R2.fastq.gz`. 
2. Sample names are represented by the "read 1" file name with `_R1.fastq.gz` stripped from the end. Output files will be the sample name with the extension `.bam` added.

Requirements:
-------------

1. [HISAT2](https://ccb.jhu.edu/software/hisat2/index.shtml) version 2.0.3-beta.
2. [samtools](http://www.htslib.org/) version 1.3.1.

Syntax:
-------

    align.sh [options] source_dir genome_file output_dir
    
---

sort_and_index_bams.sh
======================

Sorts and indexes a collection of bam files, using [samtools](http://www.htslib.org/) version 1.3.1.


Assumptions:
------------

`source_dir` contains a collection of bam files.

Requirements:
-------------

1. [samtools](http://www.htslib.org/) version 1.3.1

Syntax:
-------

    sort_and_index_bams.sh [options] source_dir dest_dir
    
---

mark_duplicates.sh
==================

Marks duplicates in a sorted, indexed bam file, using [picard](http://broadinstitute.github.io/picard/) version 2.0.1, [Java development kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html) version 1.8.0_74. Resulting bam files are re-indexed using [samtools](http://www.htslib.org/) version 1.3.1.

Assumptions:
------------

1. `source_dir` contains a collection of *sorted* bam files with read group information, with each bam file being indexed with a matching bai file.

Requirements:
-------------

1. [picard](http://broadinstitute.github.io/picard/) version 2.0.1 
2. [Java development kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html) version 1.8.0_74.
3. [samtools](http://www.htslib.org/) version 1.3.1.

Syntax:
-------

    mark_duplicates.sh [options] source_dir dest_dir
