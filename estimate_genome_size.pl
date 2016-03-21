#!perl

# estimate_genome_size.pl 
#
# estimate coverage and genome size from kmer distribution
# Copyright (C) 2012,2013 Joseph F. Ryan
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FileHandle;
use IO::Uncompress::Gunzip qw($GunzipError);
use IO::Uncompress::Bunzip2 qw($Bunzip2Error);
use IO::Uncompress::Unzip qw($UnzipError);

our $VERSION = 0.05;
our $AUTHOR  = 'Joseph F. Ryan <joseph.ryan@whitney.ufl.edu>';

MAIN: {
    my $kmer = '';
    my $peak = '';
    my $opt_version = 0;
    my $opt_help    = 0;
    my @fastq = ();

    my $result = GetOptions('kmer=i' => \$kmer,
                           'fastq=s' => \@fastq,
                            'peak=f' => \$peak,
                           'version' => \$opt_version,
                              'help' => \$opt_help);
    $opt_version && version();
    pod2usage({-exitval => 0, -verbose => 2}) if $opt_help;
    die usage() unless ($kmer && $peak && @fastq);
    my ($readlen,$total_nts) = get_readlen_and_total_nts(\@fastq);
    my $coverage = ($peak * $readlen) / ($readlen - $kmer + 1);
    my $genome_size = $total_nts / $coverage;
    print "# running version $VERSION of estimate_genome_size.pl\n";
    print "# run with this command: $0 @ARGV\n";
    print "\n";
    print "TOTAL_NTS: $total_nts\n";
    print "Estimated Coverage: $coverage\n";
    print "Estimated Genome Size: $genome_size\n";
}

sub get_readlen_and_total_nts {
    my $ra_files = shift;
    my $counter = 0;
    my $readlen = 0;
    my $fh = {};

    foreach my $file (@{$ra_files}) {
        $counter += 2;
        $fh = get_fh($file); 
        my $devnull = <$fh>;
        my $read = <$fh>;
        chomp $read;
        if ($counter == 2) {
            $readlen = length($read);
        } else {
            die "fastqs have different readlens" unless ($readlen == length($read));
        }
        while (<$fh>) {
            $counter ++;
        }
    }
    my $total = ($counter / 4) * $readlen;
    return ($readlen,$total);
}

sub get_fh {
    my $file = shift;
    my $fh = {};
    if ($file =~ m/\.gz$/i) {
        $fh = IO::Uncompress::Gunzip->new($file)
            or die "IO::Uncompress::Gunzip of $file failed: $GunzipError\n";
    } elsif ($file =~ m/\.bz2$/i) {
        $fh = IO::Uncompress::Bunzip2->new($file)
            or die "IO::Uncompress::Bunzip2 of $file failed: $Bunzip2Error\n";
    } elsif ($file =~ m/\.zip$/i) {
        $fh = IO::Uncompress::Unzip->new($file)
            or die "IO::Uncompress::Unzip of $file failed: $UnzipError\n";
    } else {
        $fh = FileHandle->new($file,'r');
        die "cannot open $file: $!\n" unless(defined $fh);
    }
    return $fh;
}
                            
sub version {
    die "estimate_genome_size.pl $VERSION\n";
}

sub usage {
    die "$0 --kmer=KMERLEN --peak=PEAK --fastq=fastq [--fastq=fastq]\n";
}

__END__

=head1 NAME

B<estimate_genome_size.pl> - use jellyfish peak and fastq files to estimate genome size and coverage

=head1 AUTHOR

Joseph F. Ryan <joseph.ryan@whitney.ufl.edu>

=head1 SYNOPSIS

estimate_genome_size.pl --kmer=KMERLEN --peak=PEAK --fastq=FASTQ [--fastq=FASTQ]

=head1 DESCRIPTION

After running jellyfish with a particular KMERLEN and one or more FASTQ files,
determine the PEAK using jellyplot.pl and find_valleys.pl. Next, use this
PEAK as well as the KMERLEN and the FASTQ files used in the jellyfish run
as input. The script will determine the coverage and genome size.

=head1 TYPICAL SESSION

=over 2

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

=back

=head1 BUGS

Please report them to <joseph.ryan@whitney.ufl.edu>

=head1 COPYRIGHT

Copyright (C) 2012 Joseph F. Ryan 

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

