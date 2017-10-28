#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

# Check for the correct number of parameters
if ( $#ARGV != 6 ) {
	die "Wrong parameter!\nUsage: perl gruenhgw_a4.pl File1.fa Query_Sequence Match_Score Mismatch_Penalty Gap_Penalty Maximum_Errors all/one\n";
}

# Save the input arguments
my ($genesFile, $querySeq, $mScore, $MScore, $IScore, $maxErrors, $mode) = @ARGV;

# Save all the genes' sequences in %SeqHash, where the name of the gene is the 
# key and the value is the sequence. Save all the genes' descriptions in 
# %DescHash, where the name of the gene is the key and the value is the description.
my ( %SeqHash, %DescHash ) = ();
my $stream = Bio::SeqIO->new( -file => $genesFile, -format => 'fasta' );
while ( my $seq_objt = $stream->next_seq() ) {
	my $seq_name = $seq_objt->display_id();
	my $seq_desc = $seq_objt->desc();
	my $seq_base = $seq_objt->seq();
	( $SeqHash{$seq_name}, $DescHash{$seq_name} ) = ( $seq_base, $seq_desc );
}

# Align the query sequence against every all the genes' sequences
foreach my $gene (keys %SeqHash) {
	my $min_map_len = length($querySeq) - $maxErrors;
	my $AlignObject=Align->new(-seq1=>$querySeq, 			# query sequence
	                           -seq2=>$SeqHash{$gene},	 	# target sequence
	                           -match=>$mScore,             # match score                       
	                           -mismatch=>$MScore,          # mismatch penalty                              
	                           -gap=>$IScore,               # gap penalty
	                           -min_map_len=>$min_map_len,  # the minimum length of a valid result
	                           -max_error=>$maxErrors,		# maximum errors allowed
	                           -mode=>$mode 				# mode=all or one
	                           );   
}



#====================================================================Subroutines
