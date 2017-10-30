package Align;
use strict;
no warnings 'recursion';

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
	my $myseq = $self->{'-seq2'};
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

sub getAlignment {
	my $self = shift;
	$::querySeq = $self->{'-seq1'};
	$::targetSeq = $self->{'-seq2'};
#	@::score;	# a 2D matrix that stores the score
#	@::path;	# a 2D matrix that stores the path
	$::cols = length($::targetSeq);
	$::rows = length($::querySeq);
	$::match = $self->{'-match'};
	$::gap = $self->{'-gap'};
	$::mismatch = $self->{'-mismatch'};
	$::gene = $self->{'-gene_name'};
	$::min_map_len = $self->{'-min_map_len'};
	$::maxErrors = $self->{'-max_error'};
	
	_initializeMatrix();	
	_align(1, 1);
	
	
	my @tmpArray = split(//, $::targetSeq);
	my @tmpArray2 = split(//, $::querySeq);
	my $queryCounter = 0;
	print "\t\t";
	foreach my $i (@tmpArray) {
		print "$i\t\t";
	}
	print "\n\t";
	for (my $row = 0; $row <= $::rows; $row++) {
		for (my $col = 0; $col <= $::cols; $col++) {
			if ($col == 0 && $row != 0)		 {	
				print $tmpArray2[$queryCounter]."\t";
				$queryCounter++;
			}
			print "$::score[$row][$col]";
			
			if ($row == 0 && $col != 0)	{	print "     ";						}
			if ($row != 0 && $col != 0) {	print "($::path[$row][$col])\t";	}
			else 						{	print "\t";							}
			if ($col == $::cols) 		{	print "\n";							}
		}	
	}
	
	_printAlignmentResults();
	print "\n";
	
}

#===============================================================>Private Methods

sub _align {
	my ($row, $col) = @_;
	
	if ($row != $::rows+1) {
		my $isMismatch = 0;
		my $diagScore = $::score[$row-1][$col-1];
		if (substr($::querySeq, $row-1, 1) eq substr($::targetSeq, $col-1, 1)) {
			$diagScore += $::match;
		}
		else {
			$diagScore += $::mismatch;
			$isMismatch = 1;
		}
		my $vertScore = $::score[$row-1][$col] + $::gap;
		my $horzScore = $::score[$row][$col-1] + $::gap;
		
		# Find which direction gives the maximum score and store it in the 2D
		# score array. Then store the direction in the 2D path array.
		my ($maxScore, $maxPath) = ($diagScore, "d"."$isMismatch");
		if ($vertScore > $maxScore)		{	($maxScore, $maxPath) = ($vertScore, "v");		}
		if ($horzScore > $maxScore)		{	($maxScore, $maxPath) = ($horzScore, "h");		}
		if ($maxScore < 0)				{	$maxScore = 0;									}
		$::score[$row][$col] = $maxScore;
		$::path[$row][$col] = $maxPath;
		
		# Make a recursive call to _align
		if ($col == $::cols) 	{	_align($row+1, 1);		}
		else 					{	_align($row, $col+1);	}
	}
}

sub _initializeMatrix {
	for (my $row = 0; $row <= $::rows; $row++) {
		$::score[$row][0] = 0;
	}
	for (my $col = 0; $col <= $::cols; $col++) {
		$::score[0][$col] = 0;
	}
}

sub _printAlignmentResults {

	# Find the highest scoring positions
	my $highScore = 0;
	my (@highPositions);
	for ( my $row = 1 ; $row <= $::rows ; $row++ ) {
		for ( my $col = 1 ; $col <= $::cols ; $col++ ) {
			if ( $::score[$row][$col] > $highScore ) {
				$highScore = $::score[$row][$col];
				splice(@highPositions);
				push @highPositions, "$row\t$col";
			}
			elsif ( $::score[$row][$col] == $highScore ) {
				push @highPositions, "$row\t$col";
			}
		}
	}

	my %results = ();
	my $validResults = 0;

	for ( my $i = 0 ; $i <= $#highPositions ; $i++ ) {
#		print "\n[" . ( $i + 1 ) . "] seq" . ( $i + 1 ) . " vs. $::gene\n\n";

		# Find the CIGAR string and the string that helps visualize the gaps and
		# mismatches between the sequences. I call it $pairing.
		my @position = split( '\t', $highPositions[$i] );
		my ( $row, $col ) = ( $position[0], $position[1] );
#		print "row = $row, col = $col\n";
		my ( $cigar, $pairing, $errors ) = ( "", "", 0 );
		while ( $row != 0 && $col != 0 ) {
#			print "row = $row, col = $col, path = $::path[$row][$col]\n";
			if ( $::path[$row][$col] eq "v" ) {
				$cigar   = "D" . $cigar;
				$pairing = " " . $pairing;
				( $row--, $errors++ );
			}
			elsif ( $::path[$row][$col] eq "h" ) {
				$cigar   = "I" . $cigar;
				$pairing = " " . $pairing;
				( $col--, $errors++ );
			}
			else {
				if ( $::path[$row][$col] =~ /1/ ) {
					$cigar = "M" . $cigar;
					$errors++;
					$pairing  = " ".$pairing;
				}
				else {
					$cigar = "m" . $cigar;
					$pairing = "|" . $pairing;
				}
				( $row--, $col-- );
			}
		}

		# Check to see if the errors in this alignment are greater than allowed
		# TODO delete errors
#		$errors =0;
		if ( $errors <= $::maxErrors ) {
			# Backtrack on the target to get its alignment string
			( $row, $col ) = ( $position[0], $position[1] );
			my $targetResult = "";
			while ( $row != 0 && $col != 0 ) {
				if ( $::path[$row][$col] eq "v" ) {
					$targetResult = "-" . $targetResult;
					( $row-- );
				}
				else {
					$targetResult = substr( $::targetSeq, $col - 1, 1 ) . $targetResult;
					if   ( $::path[$row][$col] eq "h" ) { 	$col--; 				}
					else                                { 	( $row--, $col-- ); 	}
				}
			}
			my $startEnd = ($col+1)."\t".($position[1]);
			

			# Backtrack on the query to get its alignment string
			( $row, $col ) = ( $position[0], $position[1] );
			my $queryResult = "";
			while ( $row != 0 && $col != 0 ) {
				if ( $::path[$row][$col] eq "h" ) {
					$queryResult = "-" . $queryResult;
					( $col-- );
				}
				else {
					$queryResult = substr( $::querySeq, $row - 1, 1 ) . $queryResult;
					if   ( $::path[$row][$col] eq "v" ) { 	$row--; 				}
					else                                { 	( $row--, $col-- ); 	}
				}
			}
			
			$validResults++;			
			$results{$validResults} = $startEnd."\t".$targetResult."\t".$pairing."\t".$queryResult."\t".$cigar;
		}
	}
	
	print "\n[Scoring schema]: match=$::match, mismatch=$::mismatch, gap=$::gap\n";
	print "[Search target]: $::querySeq\n";
	print "[Maximum target length]: " . ( length($::querySeq) + $::maxErrors ) . "\n";
	print "[Minimum target length]: " . $::min_map_len . "\n";
	print "[Maximum allowed error bases]: " . $::maxErrors . "\n";
	print "[The highest alignment score]: " . $highScore . "\n";
	print "[The alignments with the highest score]: $validResults\n";
	
	my $printCounter = 0;
	foreach my $result (sort {$a <=> $b} keys %results) {
		print "\n[$result] seq$result vs $::gene\n\n";
		my @tmpArray = split('\t', $results{$result});
		print "$tmpArray[0] $tmpArray[2] $tmpArray[1]\n";
		print " " x (length($tmpArray[0])+1);
		print "$tmpArray[3]\n";
		print " " x (length($tmpArray[0])+1);
		print "$tmpArray[4]\n";
		print " " x (length($tmpArray[0])+1);
		print "$tmpArray[5]\n";
	}
	
}
1;