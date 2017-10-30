package SeqAnalysis;
use strict;
use Data::Dumper;

sub new {
	my $class = shift;
	my %args  = @_;

	my $self = bless {}, $class;

	foreach my $key ( keys %args ) {
		$self->{$key} = $args{$key};
	}

	return $self;
}

#=======================================================================>Methods
sub printWithSpacer {
	my $self  = shift;
	my $myseq = $self->{'-sequence'};
	##  Put your core code for Assignment No.1 here, which will print a scale, label and spacer.
	##  You can use print statements here to print nucleotides with spacers.
	my $nts        = 100;
	my $cols       = $nts / 10;
	my $lineNumber = 0;

	# print the top row: the column numbers
	print "    ";
	for ( my $col = 1 ; $col <= $cols ; $col++ ) {
		for ( my $space = 0 ; $space < 9 ; $space++ ) {
			print " ";
		}
		print $col == 10 ? $col : " $col";
	}

	# print the 2nd to the top row: the sub-column numbers
	print "\nLine";
	for ( my $col = 1 ; $col <= $cols ; $col++ ) {
		print(" ");
		for ( my $subCol = 1 ; $subCol <= 10 ; $subCol++ ) {
			print $subCol % 10;
		}
	}

	# Print the sequence properly spaced
	for ( my $i = 0 ; $i < length($myseq) ; $i++ ) {

		# print the line number, but properly spaced for multiple digits
		if ( $i % $nts == 0 ) {
			print "\n";
			for ( my $space = 0 ; $space < 3 - ( $lineNumber + 1 ) / 10 ; $space++ ) {
				print " ";
			}
			print( ( $lineNumber + 1 ) . " " );
			$lineNumber++;
		}

		# Print the spaces if needed
		elsif ( $i % 10 == 0 && $i % $nts != 0 ) {
			print " ";
		}

		# Print the actual nucleotide
		print substr( $myseq, $i, 1 );
	}
	print "\n\n";
}

sub nucleotideCounter {
	my $self  = shift;
	my $myseq = $self->{"-sequence"};
	##  you need to write some codes here to get A/T/G/C and other base counts
	##  the print statement for “Nucleotide Counts: A=130 T=145 G=135 C=126 N=0”
	##  cannot be in this function. Instead, it must be in your main program.
	return ( ( $myseq =~ tr/A// ), ( $myseq =~ tr/T// ), ( $myseq =~ tr/G// ), ( $myseq =~ tr/C// ), ( $myseq =~ tr/N// ) );
}

sub gcContentSeqLength {
	my $self  = shift;
	my $myseq = $self->{"-sequence"};
	my ( $GCcontent, $SeqLength ) = ( 0, 0 );
	## You need to invoke nucleotideCounter()get relevant nucleotide account
	## Then, you will calculaate total sequence length and GC content value
	my ( $a, $t, $g, $c, $n ) = $self->nucleotideCounter();
	$SeqLength = $a + $t + +$g + $c + $n;
	$GCcontent = ( $g + $c ) / $SeqLength;
	return ( $GCcontent, $SeqLength );
}

sub detectEnzyme {
	my $self  = shift;
	my $myseq = $self->{"-sequence"};
	##  you only need to detect aforementioned 4 restriction enzymes and their start positions
	##  The print statement for the names, positions and sequences of detected enzymes can be here,
	##      therefore, you do not need to have return statement inside this subroutine.
	##  The item numbers (e.g., No. 1, No. 2, No. 3) have to be a variable. Of course, “No.” need to be
	##  hard-coded.
	my $minLength = 7;
	my $maxLength = 8;
	for (my $i = 0; $i < length($myseq)-$minLength; $i++) {
		if (substr($myseq, $i, $minLength) =~ /ACAAGGG/) 		{	
			print "BclI\t$i\tsubstr($myseq, $i, $minLength)\tACAAGGG\tACAAGGG\n";	
		}
		elsif (substr($myseq, $i, $minLength) =~ /TGGCC[CT]/) 	{	
			print "Cac8I\t$i\t".substr($myseq, $i, $minLength)."\tTGGCCY\tTGGCC[CT]\n";	
		}
		elsif ($i < length($myseq)-$maxLength && substr($myseq, $i, $maxLength) =~ /GG[AG]GCA[CT]T/) {	
			print "BfmI\t$i\t".substr($myseq, $i, $maxLength)."\tGGRGCAYT\tGG[AG]GCA[CT]T\n";	
		}
		elsif ($i < length($myseq)-$maxLength && substr($myseq, $i, $maxLength) =~ /AGG[ACGT]TTTA/)  {
			print "EcoRI\t$i\t".substr($myseq, $i, $maxLength)."\tAGGNTTTA\tAGG[ACGT]TTTA\n";
		}
	}
	print "\n";	
}

sub dinucleotideFrequency {
	my $self           = shift;
	my $dinucletideRef = shift;
	my %dinucleotides  = %{$dinucletideRef};
	my $myseq          = $self->{"-sequence"};
	##  You need to examine all dinucleotides existing in the given sequence
	##  You do not need to consider the reverse complementary sequence
	##  In your main program, you need to set up a hash for 16 dinucleotide with 0 as initial value.
	##  Then, you need to have print statement in main program to print this hash to get output similar
	##  to what is shown as [5] in the previous page.
	my $totalDiN = 0;
	foreach $a ( 'A', 'T', 'G', 'C' ) {
		foreach $b ( 'A', 'T', 'G', 'C' ) {
			my $diN = $a . $b;
			$dinucleotides{$diN} = () = $myseq =~ /$diN/g;
			$totalDiN += $dinucleotides{$diN};
		}
	}
	foreach my $diN ( keys %dinucleotides ) {
		$dinucleotides{$diN} = $dinucleotides{$diN} / $totalDiN;
	}

	return \%dinucleotides;
}

sub detectPolyaSignal {
	my $self  = shift;
	my $myseq = $self->{"-sequence"};
	# CS and BIO students have different tasks    my $myseq=shift;
	##  The print statements for the detected poly(A) signals can be here in this subroutine.
	##  Therefore, you should not have a return statement here.
	##  For biology students, you can use exact match.
	##  For computer science students, both exact and fuzzy matches (i.e., one base difference, but not
	##  in first, third and last positions of AATAAA) should be allowed.
	my $polyASeq   = "AATAAA";
	my $polyACounter = 1;
	for ( my $i = 0 ; $i < length($myseq) ; $i++ ) {
		if ( substr( $myseq, $i, length($polyASeq) ) =~ /A\wT\w\wA/ ) {
			print "$polyACounter\t$i\t".($i+6)."\t".substr( $myseq, $i, length($polyASeq) )."\n";
		}
	}

}

sub codonUsage {
	my $self      = shift;
	my $codonsRef = shift;
	my %codons    = %{$codonsRef};
	my $myseq     = $self->{"-sequence"};

	# For CS students only
	##  You need to examine all codons existing in the given sequence
	##  You also need to consider the reverse complementary sequence
	##  The ratio for a particular codon will be its number divided by the total codon
	##  In main program, you need to define %codon_distribution, which can be updated here.
	##  This function is for computer science students only. The relevant print statements in main
	##  program will need to generate the output similar to [6] shown in the previous page
	my $revComp = $myseq;
	$revComp =~ tr/[ATGC]/[TACG]/;
	$revComp = reverse($revComp);

	my $totalCodons = 0;
	foreach my $a ( 'A', 'T', 'G', 'C' ) {
		foreach my $b ( 'A', 'T', 'G', 'C' ) {
			foreach my $c ( 'A', 'T', 'G', 'C' ) {
				my $codon = $a . $b . $c;
				$codons{$codon} = () = $myseq =~ /$codon/g;
				$totalCodons += $codons{$codon};
			}
		}
	}
	foreach my $codon ( keys %codons ) {
		$codons{$codon} = $codons{$codon} / $totalCodons;
	}

	return \%codons;
}

sub detectMotifs { 
	# This method searches the sequence for motifs.
	# Paramters: The query motifs
	# Outputs: A hash with the motif as the key and each start position where 
	#          the motif was found, seperated by a tab, as the value.
	my $self   = shift;
	my @motifs = @_;
	my $myseq  = $self->{"-sequence"};

	
	my %motifHash = ();
	foreach my $motif (@motifs) {
		for ( my $i = 0 ; $i < length($myseq)-length($motif) ; $i++ ) {
			if ( substr($myseq, $i, length($motif)) eq $motif ) {
				$motifHash{$motif} .= "$i\t";
			}
		}
	}
	foreach my $motif (@motifs) {
		if ( !defined $motifHash{$motif} ) {
			# If the motif is not found in the sequence that store -1.
			# I'm using -1 instead of 0 to distinguish between finding a motif
			# at position 0 vs not finding it at all.
			$motifHash{$motif} = -1;
		}
	}
	
	return \%motifHash;
}

sub detectMotifsWithLabels {
	# This method searches the sequence for motifs that are denoted by a tag.
	# Paramters: A hash of the tags as the key and the motif as the value
	# Outputs: A hash with the tag and motif as the key and each start position  
	#          where the motif was found, seperated by a tab, as the value.
	my $self   = shift;
	my %tagMotif = @_;
	my $myseq  = $self->{"-sequence"};
	
	my %motifHash = ();
	foreach my $tag (keys %tagMotif) {
		my $motif = $tagMotif{$tag};
		for ( my $i = 0 ; $i < length($myseq) ; $i++ ) {
			if ( substr($myseq, $i, length($motif)) eq $motif ) {
				$motifHash{"$tag\t$motif"} .= "$i\t";
			}
		}
	}
	foreach my $tag (keys %tagMotif) {
		my $motif = $tagMotif{$tag};
		if ( ! defined $motifHash{"$tag\t$motif"} ) {
			# If the motif is not found in the sequence that store -1.
			# I'm using -1 instead of 0 to distinguish between finding a motif
			# at position 0 vs not finding it at all.
			$motifHash{"$tag\t$motif"} = -1;
		}
	}
	
	return \%motifHash;
}
1;