#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
use GeneList;
use SeqAnalysis;

# Check for the correct number of parameters
if ( $#ARGV != 2 ) {
	die "Wrong parameter!\nUsage: perl gruenhgw_a2.pl File1.txt File2.txt File3.fasta\n";
}

# Save the input files
my ( $file1, $file2, $file3 ) = @ARGV;

# Get group1Name and group2Name from the first input file
open( FILE, "<$file1" ) or die "Cannot open $file1 for processing!\n";
my $line1 = <FILE>;
chomp($line1);
my @tmpArray = split( '\t', $line1 );
my ($group1Name, $group2Name) = (substr($tmpArray[1], 3, 1), substr($tmpArray[2], 3, 1));

# Get group3Name from the second input file
open( FILE, "<$file2" ) or die "Cannot open $file2 for processing!\n";
$line1 = <FILE>;
chomp($line1);
@tmpArray = split( '\t', $line1 );
my $group3Name = substr($tmpArray[2], 3, 1);

# Store the geneID and sequences from the fasta file
my (%SeqHash, %DescHash) = ();
my $stream = Bio::SeqIO->new(-file => $file3, -format => 'fasta');
while (my $seq_objt=$stream->next_seq()) {
    my $seq_name=$seq_objt->display_id();
    my $seq_desc=$seq_objt->desc(); 
    my $seq_base=$seq_objt->seq(); 
    ($SeqHash{$seq_name}, $DescHash{$seq_name}) = ($seq_base, $seq_desc);
}

# Get the gene sets from the first two input files and store them in a hash
my $object1=GeneList->new(-gene_list_one=>$file1, -gene_list_two=>$file2);
my $hashRef1=$object1->getCommonList();     
my $hashRef2=$object1->getUnique1List();
my $hashRef3=$object1->getUnique2List();

my %CommonList = %{$hashRef1};
my %Unique1List = %{$hashRef2};
my %Unique2List = %{$hashRef3};

# Print the results for all the common gene set and the gene sets unique to
# just file1 and file2.
print "Comparison results for 2 files: $file1 and $file2\n\n";
print "+ means up-regulated gene\n";
print "- means down-regulated gene\n";
print ". means genes without striking change\n";
print "X means genes detectable only in one group [$group1Name|$group2Name|$group3Name]\n";

print "\n[1] Common gene set \n";
foreach my $gene ( sort keys %CommonList ) {
	my @expression = split( "\t", $CommonList{$gene} );
	my $group1vs2 = compareExpression( $expression[0], $expression[1], $group1Name, $group2Name );
	my $group3vs1 = compareExpression( $expression[2], $expression[0], $group3Name, $group1Name );
	print "$gene $file1 ($group1Name vs $group2Name: $group1vs2); $file2 ($group3Name vs $group1Name: $group3vs1)\n";
}

print "\n[2] Gene set unique to $file1\n";
foreach my $gene ( sort keys %Unique1List) {
	my @expression = split( "\t", $Unique1List{$gene} );
	my $group1vs2 = compareExpression( $expression[0], $expression[1], $group1Name, $group2Name );
	print "$gene ($group1Name vs $group2Name: $group1vs2)\n";
}

print "\n[3] Gene set unique to $file2\n";
foreach my $gene ( sort keys %Unique2List) {
	my @expression = split( "\t", $Unique2List{$gene} );
	my $group3vs1 = compareExpression( $expression[1], $expression[0], $group3Name, $group1Name );
	print "$gene ($group3Name vs $group1Name: $group3vs1)\n";
}

#============================================================Displaying Gene Set
print "\nWhich gene set do you want to examine [1|2|3]?\n";
my $geneSet = <STDIN>;
my @geneSet = ();
chomp($geneSet);

if ( $geneSet != 1 && $geneSet != 2 && $geneSet != 3 ) { die "Pick a valid gene set.\n"; }
elsif ( $geneSet == 1 ) { @geneSet = sort keys %CommonList; }
elsif ( $geneSet == 2 ) { @geneSet = sort keys %Unique1List; }
elsif ( $geneSet == 3 ) { @geneSet = sort keys %Unique2List; }

# Print SeqAnlaysis methods for each gene in the chosen gene set
foreach my $gene (@geneSet) {
	my $object2=SeqAnalysis->new(-seq_name=>$gene, 
								 -sequence=>$SeqHash{$gene},
								 -desc=>$DescHash{$gene});
	my %dinucleotides = ();
	foreach $a ('A', 'T', 'G', 'C') {
		foreach $b ('A', 'T', 'G', 'C') {
			$dinucleotides{$a.$b} = 0;
		}
	}
	print "$gene $DescHash{$gene}\n";
	$object2->printWithSpacer();
	my ($a, $t, $g, $c, $n) 		= $object2->nucleotideCounter();
	my ( $GCcontent, $SeqLength )	= $object2->gcContentSeqLength();
#	$object2->detectEnzyme();
	my $dinucleotidesRef = $object2->dinucleotideFrequency(\%dinucleotides);
	%dinucleotides = %{$dinucleotidesRef};
#	$object2->detectPolyaSignal();
#	$object2->codonUsage();
	
	print "[1] Nucleotide Counts: A=$a, T=$t, G=$g, C=$c, Other=$n\n";
	print "[2] GC Content: $GCcontent\n";
	print "[3] Sequence Length: $SeqLength\n";
	print "[5] Dinucleotide Frequency (%): \n";
	my $diNCounter = 1;
	foreach my $diN (keys %dinucleotides) {
		printf"[$diN]=$dinucleotides{$diN} ";
		if ($diNCounter % 4 == 0) 	{	print "\n";	}
		$diNCounter++;
	}
}

#====================================================================Subroutines
# Subroutine for comparing the gene expression between two groups and
# categorizing the regulation compared to one another.
sub compareExpression {
	my ( $expression1, $expression2, $group1Name, $group2Name ) = @_;
	my $reg = '';
	if    ( $expression1 == 0 && $expression2 == 0 ) { $reg = "no expression"; }
	elsif ( $expression1 == 0 && $expression2 != 0 ) { $reg = $group2Name; }
	elsif ( $expression1 != 0 && $expression2 == 0 ) { $reg = $group1Name; }
	elsif ( $expression2 / $expression1 >= 2 )   { $reg = "+"; }
	elsif ( $expression2 / $expression1 <= 0.5 ) { $reg = "-"; }
	else                                         { $reg = "."; }
	return $reg;
}
#
#sub printWithSpacer {
#	my $myseq = shift;
#	# TODO Delete Liang's Comments
#	##  Put your core code for Assignment No.1 here, which will print a scale, label and spacer.
#	##  You can use print statements here to print nucleotides with spacers.
#	my $nts        = 100;
#	my $cols       = $nts / 10;
#	my $lineNumber = 0;
#
#	# print the top row: the column numbers
#	print "    ";
#	for ( my $col = 1 ; $col <= $cols ; $col++ ) {
#		for ( my $space = 0 ; $space < 9 ; $space++ ) {
#			print " ";
#		}
#		print $col == 10 ? $col : " $col";
#	}
#
#	# print the 2nd to the top row: the sub-column numbers
#	print "\nLine";
#	for ( my $col = 1 ; $col <= $cols ; $col++ ) {
#		print(" ");
#		for ( my $subCol = 1 ; $subCol <= 10 ; $subCol++ ) {
#			print $subCol % 10;
#		}
#	}
#
#	# Print the sequence properly spaced
#	for ( my $i = 0 ; $i < length($myseq) ; $i++ ) {
#
#		# print the line number, but properly spaced for multiple digits
#		if ( $i % $nts == 0 ) {
#			print "\n";
#			for ( my $space = 0 ; $space < 3 - ( $lineNumber + 1 ) / 10 ; $space++ ) {
#				print " ";
#			}
#			print( ( $lineNumber + 1 ) . " " );
#			$lineNumber++;
#		}
#
#		# Print the spaces if needed
#		elsif ( $i % 10 == 0 && $i % $nts != 0 ) {
#			print " ";
#		}
#
#		# Print the actual nucleotide
#		print substr( $myseq, $i, 1 );
#	}
#	print "\n";
#}
#
#sub nucleotideCounter {
#	my $myseq = shift;
#	##  you need to write some codes here to get A/T/G/C and other base counts
#	##  the print statement for “Nucleotide Counts: A=130 T=145 G=135 C=126 N=0”
#	##  cannot be in this function. Instead, it must be in your main program.
#	return (($myseq =~ tr/A//), ($myseq =~ tr/T//), ($myseq =~ tr/G//), ($myseq =~ tr/C//), ($myseq =~ tr/N//));
#}
#
#sub gcContentSeqLength {
#	my $myseq = shift;
#	my ( $GCcontent, $SeqLength ) = ( 0, 0 );
#	## You need to invoke nucleotideCounter()get relevant nucleotide account
#	## Then, you will calculaate total sequence length and GC content value
#	my ($a, $t, $g, $c, $n) = nucleotideCounter($myseq);
#	$SeqLength = $a + $t + $c + $n;
#	$GCcontent = ($g+$c)/$SeqLength;
#	return ( $GCcontent, $SeqLength );
#}
#
#sub detectEnzyme {
#	my $myseq = shift;
#	##  you only need to detect aforementioned 4 restriction enzymes and their start positions
#	##  The print statement for the names, positions and sequences of detected enzymes can be here,
#	##      therefore, you do not need to have return statement inside this subroutine.
#	##  The item numbers (e.g., No. 1, No. 2, No. 3) have to be a variable. Of course, “No.” need to be
#	##  hard-coded.  }sub dinucleotideFrequency {    my ($myseq,$dinucleotide_hash_ref)=shift;
#	##  You need to examine all dinucleotides existing in the given sequence
#	##  You do not need to consider the reverse complementary sequence
#	##  In your main program, you need to set up a hash for 16 dinucleotide with 0 as initial value.
#	##  Then, you need to have print statement in main program to print this hash to get output similar
#	##  to what is shown as [5] in the previous page.
#}
#
#sub detectPolyaSignal {
#
#	# CS and BIO students have different tasks    my $myseq=shift;
#	##  The print statements for the detected poly(A) signals can be here in this subroutine.
#	##  Therefore, you should not have a return statement here.
#	##  For biology students, you can use exact match.
#	##  For computer science students, both exact and fuzzy matches (i.e., one base difference, but not
#	##  in first, third and last positions of AATAAA) should be allowed.
#}
#
#sub codonUsage {
#
#	# For CS students only
#	my ( $myseq, $codon_distribution_ref ) = shift;
#	##  You need to examine all codons existing in the given sequence
#	##  You also need to consider the reverse complementary sequence
#	##  The ratio for a particular codon will be its number divided by the total codon
#	##  In main program, you need to define %codon_distribution, which can be updated here.
#	##  This function is for computer science students only. The relevant print statements in main
#	##  program will need to generate the output similar to [6] shown in the previous page
#}