NOTE
======
VERSIONS 0.03 and below do not handle compressed files correctly and therefore give erroneous size estimations.  If you used uncompressed files, there is no problem.  this has been fixed in VERSION 0.04.  -- November 12, 2014

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

To install without root privelages try:

    perl Makefile.PL PREFIX=/home/myuser/scripts
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

WHAT IF YOU DON'T GET A SECOND PEAK?
------------

See this interesting discussion at SeqAnswers:
http://seqanswers.com/forums/showthread.php?t=41874

I have been asked frequently about the case of no second peak in histogram plots.
My stock answer has been that you probably don’t have enough coverage and
in most cases that means your genome is huge. But, I have never really
tested this (it would be easy enough to do this with simulated reads).
I did have a case where I got no peak and when I added more sequence later
and reran the analysis, a peak appeared. 

My latest suggestion is to run a quick assembly with SOAP or something and
then align the reads to the contigs. Check out a few of the contigs (maybe
some homeobox loci) and make sure things look OK.  You are likely to get
an very poor assembly if the coverage is too low (CEGMA can help confirm
this) and the places that assemble are likely to be those that have more
coverage than average, but you can get a feeling for how much coverage
those regions have and from that extrapolate a course estimate for the
size and overall coverage.


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

