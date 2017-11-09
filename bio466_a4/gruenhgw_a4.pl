#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
use Align;
use SeqAnalysis;

# Check for the correct number of parameters
if ( $#ARGV != 6 ) {
	die "Wrong parameter!\nUsage: perl gruenhgw_a4.pl File1.fa Query_Sequence Match_Score Mismatch_Penalty Gap_Penalty Maximum_Errors all/one\n";
}

# Save the input arguments
my ( $genesFile, $querySeq, $mScore, $MScore, $IScore, $maxErrors, $mode ) = @ARGV;

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

# Print to alignment.txt
open( FILE, ">alignment.txt" );
select FILE;

# Align the query sequence against every all the genes' sequences
foreach my $gene ( sort keys %SeqHash ) {
	my $min_map_len = length($querySeq) - $maxErrors;
	my $AlignObject = Align->new( 
		-seq1		 => $querySeq,			# query sequence
		-seq2        => $SeqHash{$gene},  	# target sequence
		-match       => $mScore,          	# match score
		-mismatch    => $MScore,          	# mismatch penalty
		-gap         => $IScore,          	# gap penalty
		-min_map_len => $min_map_len,     	# the minimum length of a valid result
		-max_error   => $maxErrors,       	# maximum errors allowed
		-mode        => $mode,            	# mode=all or one
	);

	print ">$gene $DescHash{$gene}\n";
	$AlignObject->printWithSpacer();
	
	$AlignObject->getAlignment();

	# Do all the sequence analysis from assignment 3
	#	sequenceAnalysis($gene, \%SeqHash, \%DescHash);
}

#====================================================================Subroutines
sub sequenceAnalysis {
	my ( $gene, $SeqHashRef, $DescHashRef ) = @_;
	my %SeqHash  = %{$SeqHashRef};
	my %DescHash = %{$DescHashRef};
	my $object2  = SeqAnalysis->new( -seq_name => $gene,
		-sequence => $SeqHash{$gene},
		-desc     => $DescHash{$gene} );
	my ( %dinucleotides, %codons ) = ();
	foreach my $a ( 'A', 'T', 'G', 'C' ) {
		foreach my $b ( 'A', 'T', 'G', 'C' ) {
			$dinucleotides{ $a . $b } = 0;
			foreach my $c ( 'A', 'T', 'G', 'C' ) {
				$codons{ $a . $b . $c } = 0;
			}
		}
	}

	# Make the method calls on the object and dereference the outputs
	my ( $A, $T, $G, $C, $N ) = $object2->nucleotideCounter();
	my ( $GCcontent, $SeqLength ) = $object2->gcContentSeqLength();

	my $dinucleotidesRef = $object2->dinucleotideFrequency( \%dinucleotides );
	%dinucleotides = %{$dinucleotidesRef};

	my $codonsRef = $object2->codonUsage( \%codons );
	%codons = %{$codonsRef};

	my $motifHashRef = $object2->detectMotifs( 'CAT', 'GAT', 'TAG' );
	my %motifHash = %{$motifHashRef};

	my $tagMotifHashRef = $object2->detectMotifsWithLabels( 'A1' => 'CAT', 'A2' => 'GAT', 'A3' => 'TAG' );
	my %tagMotifHash = %{$tagMotifHashRef};

	# Print the dereferenced outputs of the methods
	print "[1] Nucleotide Counts: A=$A, T=$T, G=$G, C=$C, Other=$N\n";
	print "[2] GC Content: $GCcontent\n";
	print "[3] Sequence Length: $SeqLength\n";

	print "[4] Restriction Sites:\n\n";
	print "Name\tPos\tSeq\t\tIUPAC\t\tALT\n";
	$object2->detectEnzyme();

	print "[5] Dinucleotide Frequency (%): \n\n";
	my $diNCounter = 1;
	foreach my $diN ( keys %dinucleotides ) {
		printf "[$diN]=%.3f ", $dinucleotides{$diN};
		if ( $diNCounter % 4 == 0 ) { print "\n"; }
		$diNCounter++;
	}

	print "\n[6] Detection of poly(A) signal (AATAAA): \n\n";
	print "No.\tStart\tEnd\tSignal\n";
	$object2->detectPolyaSignal();

	print "\n[7] Codon Usage:\n\n";
	my $codonCounter = 1;
	foreach my $codon ( keys %codons ) {
		printf "[$codon]=%.3f ", $codons{$codon};
		if ( $codonCounter % 4 == 0 ) { print "\n"; }
		$codonCounter++;
	}

	print "\n[8] Detection of motifs without labels: \n(";
	my @motifs = sort keys %motifHash;
	for ( my $i = 0 ; $i <= $#motifs ; $i++ ) {
		print "\'$motifs[$i]\'";
		if   ( $i != $#motifs ) { print ", "; }
		else                    { print ")\n\nMotif\t\tStart\tEnd\n"; }
	}
	foreach my $motif (@motifs) {
		my @tmpArray = split( '\t', $motifHash{$motif} );
		foreach my $motifStart (@tmpArray) {
			my $motifEnd = $motifStart + length($motif);
			if ( $motifStart == -1 ) {
				$motifStart = 0;
				$motifEnd   = 0;
			}
			print "$motif\t\t$motifStart\t$motifEnd\n"
		}
	}

	print "\n[9] Dection of motifs with labels: (";
	my @tagMotif = sort keys %tagMotifHash;
	for ( my $i = 0 ; $i <= $#tagMotif ; $i++ ) {
		my @tmpArray = split( '\t', $tagMotif[$i] );
		print "\'$tmpArray[0]\'=>\'$tmpArray[1]\'";
		if   ( $i != $#tagMotif ) { print ", "; }
		else                      { print ")\n\nLabel\tMotif\t\tStart\tEnd\n"; }
	}
	foreach my $key (@tagMotif) {
		my @tmpArray = split( '\t', $tagMotifHash{$key} );
		foreach my $motifStart (@tmpArray) {
			my @motifTag = split( '\t', $key );
			my $motif    = $motifTag[1];
			my $motifEnd = $motifStart + length($motif);
			if ( $motifStart == -1 ) {
				$motifStart = 0;
				$motifEnd   = 0;
			}
			print "$key\t\t$motifStart\t$motifEnd\n";
		}
	}
	print "\n";
}
