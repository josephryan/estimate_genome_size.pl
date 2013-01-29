estimate_genome_size.pl
======

this is a suite of perl scripts to help estimate genome size from KMER distributions. It has been tested with the JELLYFISH program
http://www.cbcb.umd.edu/software/jellyfish/

The output looks something like:

    Estimated Coverage: 59.5 (60X) Estimated Genome Size: 1010144681.14286 (1GB) 

INSTALLATION
------------

To install this script and documentation type the following:

    perl Makefile.PL
    make
    make install

RUN
---

    estimate_genome_size.pl [--version] [--help] --kmer=KMERLEN --peak=PEAK --fastq=fastq [--fastq=fastq]

for detailed documenation

    perldoc estimate_genome_size.pl
    perldoc find_valleys.pl
    perldoc jellyplot.pl

DEPENDENCIES
------------

This module requires Perl

You will also want JELLYFISH:

    http://www.cbcb.umd.edu/software/jellyfish/

For the jellyplot program you will need gnuplot in your path:

    http://www.gnuplot.info/


A TYPICAL SESSION
------------

    # count k-mers (see jellyfish documentation for options)
    gzip -dc reads1.fastq.gz reads2.fastq.gz | jellyfish count -m 31 -o fastq.counts -C -s 10000000000 -U 500 -t 30 /dev/fd/0 
    
    # generate a histogram
    jellyfish histo fastq.counts_0 > fastq.counts_0.histo

    # generate a pdf graph of the histogram
    jellyplot.pl fastq.counts_0.histo

    # look at fastq.counts_0.histo.pdf and identify the approximate peak

    # use find_valleys.pl to help pinpoint the actual peak
    find_valleys.pl fastq.counts_0.histo

    # estimate the size and coverage
    estimate_genome_size.pl --kmer=31 --peak=42 --fastq=reads1.fastq.gz reads2.fastq.gz
    
SEE THE FOLLOWING FOR THE PRINCIPLE BEHIND THE SCRIPT
------------

https://banana-slug.soe.ucsc.edu/bioinformatic_tools:jellyfish
http://seqanswers.com/forums/archive/index.php/t-10988.html
https://banana-slug.soe.ucsc.edu/bioinformatic_tools:quake

IF YOU DON'T BELIEVE IT WORKS
------------

Simulate some next generation data based on an already-sequenced genome.
I used the program ART to do this with the Hydra magnipapillata genome:

http://www.niehs.nih.gov/research/resources/software/biostatistics/art/

    art_illumina --paired --in Hm_genomic.fa --out Hm_genomic_wildtype --len 100 --fcov 43 --mflen 180 --sdev 3.5
    
I also simulated perfect paired-end data with a sliding window. In both cases I recovered the correct coverage and size.

COPYRIGHT AND LICENSE
------------

Copyright (C) 2012,2013 Joseph F. Ryan

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file gpl.txt.  If not, see
http://www.gnu.org/licenses/.

