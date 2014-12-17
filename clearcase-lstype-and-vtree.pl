#!ratlperl
#
# ClearCase timethese: List label types, List version tree
#
# Usage: $0 <vobtag> <pname> [<count>]
#
# Given vob-tag and pname, measure (via Benchmark::timethese) how long it
# takes to:
# - list lbtypes in vobtag (unsorted, default format)
# - list version tree of pname (show all labels)
#
# Will do first iteration, then the fun starts
#
# Require 'cleartool' to be present on PATH. Should work with Perl bundled
# with ClearCase.
#

use 5.008;
use strict;
use warnings;

use Benchmark;
use File::Spec;

my $_silent = sprintf(">%s", File::Spec->devnull);

sub lbtypes {
    my $vobtag = shift;

    system("cleartool lstype -kind lbtype -unsorted -invob $vobtag $_silent")
        and die("failed to lstype in $vobtag");
}

sub vtree {
    my $pname = shift;

    system("cleartool lsvtree -all $pname $_silent")
        and die("failed to lsvtree $pname");
}

# main()

my $vobtag = shift;
my $pname = shift;
my $count = shift || 10;

die "Usage: $0 <vobtag> <pname> [<count>]" unless ($vobtag and $pname);

# run both actions first to be fair (should populate whatever cache there is)
warn "dummy iteration";
lbtypes($vobtag);
vtree($pname);

timethese(
    $count,
    {
        'List label types' => sub { lbtypes($vobtag) },
        'List version tree' => sub { vtree($pname) },
    }
);
