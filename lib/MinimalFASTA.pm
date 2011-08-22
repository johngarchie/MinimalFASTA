=head1 NAME

MinimalFASTA - a minimal library for reading and printing FASTA data

=head1 SYNOPSIS

  use MinimalFASTA ':all';

  while ( my (@seq) = read_seq *STDIN ) {
      print STDERR "The sequence of $seq[FA_NAME] ";
      print STDERR "($seq[FA_DESC]) " if defined $seq[FA_DESC];
      print STDERR "is $seq[FA_SEQ].\n";

      write_seq *STDOUT, @seq;
  }

=head1 DESCRIPTION

MinimalFASTA provides the functions &read_seq and &write_seq for reading and
writing FASTA-formatted sequences to and from filehandles.

=head1 ABOUT

  Created by:	 John Archie <lt>jarchie@soe.ucsc.edu<gt>
  Created on:    2011-08-12

  SVN Information:
    $LastChangedBy:: jarchie                                            $
    $LastChangedDate:: 2011-08-13 12:40:57 -0700 (Sat, 13 Aug 2011)     $
    $LastChangedRevision:: 106                                          $
    $URL:: file:///svn/perlmod/MinimalFASTA/lib/MinimalFASTA.pm         $

=cut

package MinimalFASTA;

use warnings;
use strict;

use Carp;
use Symbol 'qualify_to_ref';

use 5.005000;
our $VERSION = 0.01;

require Exporter;
our @ISA = qw/Exporter/;

our @EXPORT_OK   = qw/FA_NAME FA_SEQ FA_DESC &read_seq &write_seq/;
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT      = qw//;    # export nothing by default


=head1 CONSTANTS

Each sequence is represented as an array containing the name, sequence, and
description (in that order) of each FASTA sequence.  This module provides the
following constants for use as sequence array indexes.

   Constant | Value | Description
  ----------|-------+------------------------
   FA_NAME  | 0     | the sequence name
   FA_SEQ   | 1     | the sequence itself
   FA_DESC  | 2     | the sequence description

=head1 FUNCTIONS

=over 4

=cut

use constant {
    FA_NAME => 0,
    FA_SEQ  => 1,
    FA_DESC => 2
};


my %line_cache; # for caching lines between subsequent &read_seq calls

=item B<read_seq(*IN)>

&read_seq attempts to fetch a sequence from *IN and return a three-element
array with the name, sequence, and description (in that order).  If the
annotation contains no description, &read_seq still returns a three-element
array, but the third element is undefined.  When no more sequences remain,
&read_seq returns an empty array.

=cut

sub read_seq(*) {
    my $fh = qualify_to_ref shift, caller;

    # scalar cache identifier to save lines across separate calls
    my $fh_key = ( defined fileno $fh ? "fd=" . fileno $fh : scalar $fh );

    # if the last line read from $fh is cached, retrieve it
    # otherwise, read another line from this glob
    my $line;
    if ( exists $line_cache{$fh_key} ) {
	$line = $line_cache{$fh_key};

	if ( not defined $line ) {
	    delete $line_cache{$fh_key};
	    return ();
	}
    } else {
	defined ( $line = <$fh> ) or croak "failed read from filehandle";
    }

    # parse annotation
    my ($name, $desc) = $line =~ /^>(\S*)(?:\s+(\S.*?))?\s*$/
	or croak "sequence annotation on line $. could not be parsed";

    carp "annotation on line $. contains empty sequence name" if $name eq "";

    # fetch sequence until next annotation or end-of-file
    my $seq = "";
    while(defined ( $line = <$fh> ) and $line !~ /^>/) {
	$line =~ s/\s+//g;
	$seq .= $line;
    }

    # store next annotation (or end-of-file) for next call
    $line_cache{$fh_key} = $line;

    return ($name, $seq, $desc);
}


=item B<write_seq(*OUT, $name, $seq, $desc)> or B<write_seq(*OUT, $name, $seq)>

&write_seq formats and prints a sequence to *OUT.  If $desc is omitted or
undefined, the sequence is printed with no description after the name on the
annotation line.

=cut

sub write_seq(*@) {
    my ($fh, $name, $seq, $comment) = ( qualify_to_ref(shift, caller), @_ );
    print $fh ">$name" . (defined $comment ? " $comment\n" : "\n");
    print $fh join("\n", $seq =~ /(.{1,60})/go), "\n";
}


=back

=head1 BUGS

In the FASTA format, &read_seq detects the end sequence lneeds to upon
reading the annotation line of the next sequence or encountering the
end-of-file.  This information is therefore cached across invocations
of &read_seq and indexed by the file descriptor as returned by fileno.
If no file descriptor exists (i.e., filehandles connected to in-memory
objects and tied filehandles), &read_seq instead coerses the
filehandle to a scalar value which must uniquely identify that file.

=head1 SEE ALSO

L<MinimalPDB>

=cut

1;
