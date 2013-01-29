
use ExtUtils::MakeMaker;

WriteMakefile(NAME      => 'estimage_genome_size.pl',
              VERSION   => '0.03',
              EXE_FILES => ['estimate_genome_size.pl', 
                            'find_valleys.pl',
                            'jellyplot.pl']);
