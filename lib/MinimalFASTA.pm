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

MinimalFASTA provides the functions for formatting, parsing, reading and
writing sequences in FASTA format.  Each sequence is represented as a
three-element array containing the name, sequence, and description (in that
order) of each sequence.  If no description exists, the third element exists
but is undefined.

=cut

package MinimalFASTA;

use warnings;
use strict;

use Carp;
use IO::Handle;
use Symbol 'qualify_to_ref';

use 5.008;
our $VERSION = 0.01;

require Exporter;
our @ISA = qw/Exporter/;


=head1 EXPORTS

Nothing is exported by default.  For convenience, most users will want to
export all constants and functions with the tag ":all", e.g.,

  use MinimalFASTA ':all';

=cut

our @EXPORT_OK   = qw/FA_NAME FA_SEQ FA_DESC
		      &read_seq &parse_seq &write_seq &format_seq/;

our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT      = qw//;    # export nothing by default

sub read_seq(*);
sub parse_seq($);
sub write_seq(*@);
sub format_seq(@);


=head1 CONSTANTS

This module provides the following constants for use as array indexes.

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


=item B<format_seq($name, $seq, $desc)> or B<format_seq($name, $seq)>

like &write_seq but returns the FASTA-formatted sequence instead.

=cut

sub format_seq(@) {
    my ($name, $seq, $desc) = @_;
    return ">$name" . (defined $desc ? " $desc\n" : "\n")
           . join("\n", $seq =~ /(.{1,60})/go) . "\n";
}


=item B<parse_seq($fa_seq)> or B<parse_seq($fa_seq)>

like &read_seq but uses the FASTA sequence stored in $fa_seq;

=cut

sub parse_seq($) {
    my ($fa_seq) = @_;

    my ($name, $desc, $seq )
	= $fa_seq =~ /^>(\S*)(?:[ \t]+(\S.*?))?[ \t]*((?:\R[^>].*)*)$/o
	    or croak "unable to parse FASTA sequence";

    carp "annotation contains empty sequence name" if $name eq "";

    $seq =~ s/\s//g;

    return ($name, $seq, $desc);
}


=item B<read_seq(*IN)>

&read_seq fetches a FASTA sequences from *IN and returns a three-element array
with the name, sequence, and description (in that order).  If the annotation
contains no description, &read_seq still returns a three-element array, but the
third element is undefined.  If no more sequences remain, &read_seq returns an
empty array.

=cut

sub read_seq(*) {
    my $fh = qualify_to_ref shift, caller;

    # read annotation line; return emty array if end-of-file
    defined ( my $line = <$fh> ) or return ();

    # parse annotation
    my ($name, $desc) = $line =~ /^>(\S*)(?:\s+(\S.*?))?\s*$/o
	or croak "unable to parse annotation (line $.)";

    carp "annotation (line $.) contains empty sequence name" if $name eq "";

    # fetch sequence until encountering annotation or end-of-file
    my ($seq, $more_sequence) = ("", 1);
    while ( $more_sequence and defined ( $line = <$fh> ) ) {
	my $next_char = $fh->getc;
	
	if ( not defined $next_char ) {	# end of file
	    $more_sequence = 0;
	}
	elsif ( $next_char eq ">" ) {	# annotation of next sequence
	    $more_sequence = 0;
	    $fh->ungetc(ord $next_char);
	}
	else {				# more sequence, yay!
	    $line .= $next_char;
	}

	$line =~ s/\s+//go;
	$seq .= $line;
    }

    return ($name, $seq, $desc);
}


=item B<write_seq(*OUT, $name, $seq, $desc)> or B<write_seq(*OUT, $name, $seq)>

&write_seq formats and prints a sequence to *OUT.  If $desc is omitted or
undefined, the sequence is printed with no description after the name on the
annotation line.

=cut

sub write_seq(*@) {
    my $fh = qualify_to_ref(shift, caller);
    print $fh format_seq @_;
}


=back

=head1 SEE ALSO

L<MinimalPDB>

=head1 BUGS AND CAVEATS

None known

=head1 AUTHOR

John Archie L<http://www.jarchie.com/>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by John Archie

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself, either Perl version 5.8.0 or, at
your option, any later version of Perl 5 you may have available.

=cut

1;
