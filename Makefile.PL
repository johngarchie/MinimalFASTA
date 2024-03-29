use 5.005000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'MinimalFASTA',
    VERSION_FROM      => 'lib/MinimalFASTA.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/MinimalFASTA.pm', # retrieve abstract from module
       AUTHOR         => 'John Archie <jarchie@>') : ()),
);
