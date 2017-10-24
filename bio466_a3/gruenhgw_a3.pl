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
	# Create the object for the gene and intialize all the dinucleotide and
	# codon hashes for the methods that will need them.
	my $object2=SeqAnalysis->new(-seq_name=>$gene, 
								 -sequence=>$SeqHash{$gene},
								 -desc=>$DescHash{$gene});
	my (%dinucleotides, %codons) = ();
	foreach my $a ('A', 'T', 'G', 'C') {
		foreach my $b ('A', 'T', 'G', 'C') {
			$dinucleotides{$a.$b} = 0;
			foreach my $c ( 'A', 'T', 'G', 'C' ) {
				$codons{$a.$b.$c} = 0;
			}
		}
	}
	print ">$gene $DescHash{$gene}\n";
	
	# Make the method calls on the object and dereference the outputs
	$object2->printWithSpacer();
	my ($A, $T, $G, $C, $N) 		= $object2->nucleotideCounter();
	my ( $GCcontent, $SeqLength )	= $object2->gcContentSeqLength();
	
	my $dinucleotidesRef = $object2->dinucleotideFrequency(\%dinucleotides);
	%dinucleotides = %{$dinucleotidesRef};
	
	my $polyASitesRef = $object2->detectPolyaSignal();
	my %polyASites = %{$polyASitesRef};
	
	my $codonsRef = $object2->codonUsage(\%codons);
	%codons = %{$codonsRef};
	
	my $motifHashRef = $object2->detectMotifs("GAATCC", "GAATGG", "GAACCCC");
	my %motifHash = %{$motifHashRef};
		
	my $tagMotifHashRef = $object2->detectMotifsWithLabels('A1'=>'GAATCC', 'A2'=>'GAATGG', 'A3'=>'GAACCCC');
	my %tagMotifHash = %{$tagMotifHashRef};
	
	# Print the dereferenced outputs of the methods
	print "[1] Nucleotide Counts: A=$A, T=$T, G=$G, C=$C, Other=$N\n";
	print "[2] GC Content: $GCcontent\n";
	print "[3] Sequence Length: $SeqLength\n";
	
	print "[4] Restriction Sites:\n\n";
	print "Name\tPos\tSeq\tIUPAC\tALT\n";
	$object2->detectEnzyme();
#	foreach my $key (sort keys %enzymes) {
#		my @tmpArray = split('\t', $enzymes{$key});
#		if ($key =~ /ACAAGGG/) {
#			foreach my $pos (sort {$a <=> $b} @tmpArray) {
#				print "BclI\t$pos\tACAAGGG";
#			}
#		}
#	}
	
	print "[5] Dinucleotide Frequency (%): \n\n";
	my $diNCounter = 1;
	foreach my $diN (keys %dinucleotides) {
		printf"[$diN]=%.3f ", $dinucleotides{$diN};
		if ($diNCounter % 4 == 0) 	{	print "\n";	}
		$diNCounter++;
	}
	
	print "\n[6] Detection of poly(A) signal (AATAAA): \n\n";
	print "No.\tStart\tEnd\tSignal\n";
	my $polyCounter = 1;
	foreach my $site (sort {$a <=> $b} keys %polyASites) {
		my $endSite = $site + 6;
		print "$polyCounter\t$site\t$endSite\t$polyASites{$site}\n";
		$polyCounter++;
	}
	
	print "\n[7] Codon Usage:\n\n";
	my $codonCounter = 1;
	foreach my $codon (keys %codons) {
		printf"[$codon]=%.3f ", $codons{$codon};
		if ($codonCounter % 4 == 0) 	{	print "\n";	}
		$codonCounter++;
	}
	
	print "\n[8] Detection of motifs without labels: \n(";
	my @motifs = sort keys %motifHash;
	for (my $i = 0; $i <= $#motifs; $i++) {
		print "\'$motifs[$i]\'"; 
		if ($i != $#motifs) {	print ", "; 						}
		else 				{	print ")\n\nMotif\t\tStart\tEnd\n";	}
	}
	foreach my $motif (@motifs) {
		print "$motif\t\t$motifHash{$motif}[0]\t".$motifHash{$motif}[1]."\n";
	}
	
	print "\n[9] Dection of motifs with labels: (";
	my @tagMotif = sort keys %tagMotifHash;
	for (my $i = 0; $i <= $#tagMotif; $i++) {
		my @tmpArray = split('\t', $tagMotif[$i]);
		print "\'$tmpArray[0]\'=>\'$tmpArray[1]\'"; 
		if ($i != $#tagMotif) 	{	print ", "; 						}
		else 					{	print ")\n\nLabel\tMotif\t\tStart\tEnd\n";	}
	}
	foreach my $key (@tagMotif) {
		print "$key\t\t$tagMotifHash{$key}[0]\t$tagMotifHash{$key}[1]\n";
	}
	print "\n";
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