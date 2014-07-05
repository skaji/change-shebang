use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Copy 'copy';
copy 'META.json' => 'MYMETA.json' if -f 'META.json';

WriteMakefile
    NAME => 'App::ChangeShebang',
    VERSION_FROM => 'lib/App/ChangeShebang.pm',
    ABSTRACT_FROM => 'lib/App/ChangeShebang.pm',
    AUTHOR => ['Shoichi Kaji <skaji@cpan.org>'],
    LICENSE => 'perl',
    EXE_FILES => [glob "bin/*"],
    NO_MYMETA => 1,
;

