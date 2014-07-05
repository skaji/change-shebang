use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

use App::ChangeShebang;

plan skip_all => "doesn't support windows!" if $^O eq 'MSWin32';

subtest basic1 => sub {
    my $tempdir = tempdir;
    spew "$tempdir/hoge$_.pl", "#!/path/to/perl\n" for 1..3;

    App::ChangeShebang->new
        ->parse_options("-f", "-q", map "$tempdir/hoge$_.pl", 1..3)
        ->run;
    is slurp("$tempdir/hoge$_.pl"), <<'...' for 1..3;
#!/bin/sh
exec "$(dirname "$0")"/perl -x -- "$0" "$@"
#!perl
#!/path/to/perl
...
};

subtest basic2 => sub {
    my $tempdir = tempdir;
    spew "$tempdir/hoge.pl", "#!/usr/bin/env perl\n";
    spew "$tempdir/hoge.rb", "#!/usr/bin/ruby\n";

    App::ChangeShebang->new
        ->parse_options("-f", "-q", "$tempdir/hoge.pl", "$tempdir/hoge.rb")
        ->run;
    is slurp("$tempdir/hoge.pl"), <<'...';
#!/bin/sh
exec "$(dirname "$0")"/perl -x -- "$0" "$@"
#!perl
#!/usr/bin/env perl
...
    is slurp("$tempdir/hoge.rb"), "#!/usr/bin/ruby\n";
};

subtest permission => sub {
    my $tempdir = tempdir;
    spew "$tempdir/hoge$_.pl", "#!/path/to/perl\n" for 1..3;
    chmod 0755, "$tempdir/hoge1.pl";
    chmod 0555, "$tempdir/hoge2.pl";
    chmod 0500, "$tempdir/hoge3.pl";

    App::ChangeShebang->new
        ->parse_options("-f", "-q", map "$tempdir/hoge$_.pl", 1..3)
        ->run;
    is slurp("$tempdir/hoge$_.pl"), <<'...' for 1..3;
#!/bin/sh
exec "$(dirname "$0")"/perl -x -- "$0" "$@"
#!perl
#!/path/to/perl
...
    is( (stat "$tempdir/hoge1.pl")[2] & 07777, 0755 );
    is( (stat "$tempdir/hoge2.pl")[2] & 07777, 0555 );
    is( (stat "$tempdir/hoge3.pl")[2] & 07777, 0500 );
};



done_testing;
