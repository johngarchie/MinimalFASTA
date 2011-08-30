# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl MinimalFASTA.t'

#########################

use warnings;
use strict;

# change 'tests => 1' to 'tests => last_test_to_print';
use Test::More tests => 6;
BEGIN { use_ok('MinimalFASTA', qw/:all/) };

#########################

## &get_seq tests
{
    my @seq = read_seq *DATA;

    is_deeply(\@seq,  ["seq1", "ACTG", "first sequence"], "&read_seq seq1");

    @seq = read_seq *DATA;

    is_deeply(\@seq,  ["seq2", "GTCA", "second sequence"], "&read_seq seq2");

    @seq = read_seq *DATA;

    is_deeply(\@seq,  [], "&read_seq end-of-file");
}

## &parse_seq tests
{
    my @test_seq = ( "SeqToParse",
		     "ACTG",
		     "parsable fasta sequence");

    my $parsable_seq =   ">" . $test_seq[FA_NAME]
		       . " " . $test_seq[FA_DESC] . "\n"
    		             . $test_seq[FA_SEQ ]  . "\n";

    my @parsed_seq = parse_seq $parsable_seq;

    is_deeply(\@parsed_seq, \@test_seq, "&parse_seq");

    my $formatted_seq = format_seq @test_seq;

    is($formatted_seq, $parsable_seq, "&format_seq");
}

__DATA__
>seq1 first sequence
AC
TG
>seq2 second sequence
GTCA
