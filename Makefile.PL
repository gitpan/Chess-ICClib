use 5.008003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Chess::ICClib',
    VERSION_FROM      => 'lib/Chess/ICClib.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Chess/ICClib.pm', # retrieve abstract from module
       AUTHOR         => 'Roman M. Parparov <romm@tau.ac.il>') : ()),
);
