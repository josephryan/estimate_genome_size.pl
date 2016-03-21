#!perl

# THIS PROGRAM REQUIRES GNUPLOT TO BE IN YOUR PATH
# http://www.gnuplot.info/

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

$|++;

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use IO::File;
use POSIX qw(tmpnam);

our $VERSION = 0.03;
our $AUTHOR  = 'Joseph F. Ryan <joseph.ryan@whitney.ufl.edu>';

our $TMP_CMD_FILE = '';
our $TMP_TAB_FILE = '';
our $GNUPLOT = 'gnuplot';

MAIN: {
    my $opt_version = 0;
    my $opt_help = 0;

    my $opt_results = Getopt::Long::GetOptions(  "version" => \$opt_version,
                                                    "help" => \$opt_help);
    $opt_version && version();
    pod2usage({-exitval => 0, -verbose => 2}) if $opt_help;

    my $file = $ARGV[0] or usage();
    make_cmd_file($file);

    if (system("$GNUPLOT $TMP_CMD_FILE\n") == 0) {
        print "pdf file written to $file.pdf\n";
    } else {
        die "system call to $GNUPLOT failed.  Is $GNUPLOT in path?\n";
    }
}

sub make_cmd_file {
    my $file = shift;
    my $fh = '';
    my $date_str = localtime();
    do { $TMP_CMD_FILE = tmpnam() }
    until $fh = IO::File->new($TMP_CMD_FILE, O_RDWR|O_CREAT|O_EXCL);
    print $fh "set terminal postscript\n";
    print $fh "set output \"| ps2pdf - $file.pdf\"\n";
    print $fh "set nokey\n";
    print $fh "set title 'K-mer plot $file (plot generated on $date_str)'\n";
    print $fh "set logscale y\n";
    print $fh "set xlabel 'multiplicity'\n";
    print $fh "set ylabel 'number-of-distinct k-mers with given multiplicity'\n";
    print $fh "plot '$file\n";
}

sub usage {
    die "usage: $0 [--version] [--help] HISTO_FILE\n";
}

sub version {
    die "jellyplot.pl $VERSION\n";
}

# install atexit-style handler so that when we exit or die,
# we automatically delete this temporary file
END { 
    if ($TMP_CMD_FILE) {
        unlink($TMP_CMD_FILE) or die "Couldn't unlink $TMP_CMD_FILE:$!"
    }
    if ($TMP_TAB_FILE) {
        unlink($TMP_TAB_FILE) or die "Couldn't unlink $TMP_TAB_FILE:$!"
    }
}

__END__

=head1 NAME

B<jellyplot.pl> - generate PDF plot of histogram

=head1 AUTHOR

Joseph F. Ryan <josephryan@yahoo.com>

=head1 SYNOPSIS

jellyplot.pl HISTO_FILE

=head1 DESCRIPTION

generate PDF plot of histogram data from jellyfish data. Requires gnuplot

=head1 BUGS

Please report them to <josephryan@yahoo.com>

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
