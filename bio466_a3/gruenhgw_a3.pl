#!/usr/bin/perl -w
use strict;
use Data::Dumper qw(Dumper);

# Check for the correct number of parameters
if ( $#ARGV != 2 ) {
	die "Wrong parameter!\nUsage: perl gruenhgw_a2.pl File1.txt File2.txt File3.fasta\n";
}

# Save the input files
my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

# Initialize a variables for the group names and the unique/common gene sets
my ( $group1Name, $group2Name, $group3Name, $file1HashRef, $file2HashRef, %allGenes, @uniqueFile1, @uniqueFile2 ) = ();

# Process the files by looking for the groupnames and storing their gene
# expression in a hash.
( $group1Name, $group2Name, $file1HashRef ) = processFile($file1);
( $group1Name, $group3Name, $file2HashRef ) = processFile($file2);
my %file1Hash = %{$file1HashRef};
my %file2Hash = %{$file2HashRef};

# Find the gene regulation for each gene, find the unique/common gene sets
foreach my $gene (keys %file1Hash) {
#	print "Hash = file1Hash, key = $gene, value = $file1Hash{ $gene }\n";
	if (!defined $file2Hash{$gene}) {
		push @uniqueFile1, $gene
	}
	else {
		$allGenes{ $gene } = $file1Hash{ $gene };
	}
}
foreach my $gene (keys %file2Hash) {
#	print "Hash = file2Hash, key = $gene, value = $file2Hash{ $gene }\n";
	if (!defined $file1Hash{$gene}) {
		push @uniqueFile2, $gene;
	}
	else {
		my @tmpArray = split( '\t', $file2Hash{$gene} );
		$allGenes{$gene} .= $tmpArray[1];
	}
}

print "Comparison results for 2 files: $file1 and $file2\n\n";
print "+ means up-regulated gene\n";
print "- means down-regulated gene\n";
print ". means genes without striking change\n";
print "X means genes detectable only in one group [$group1Name|$group2Name|$group3Name]\n";

print "[1] Common gene set \n";
foreach my $gene (sort keys %allGenes) {
	print "$gene $file1 (A vs B: ); $file2 (C vs A: )\n";
}

#====================================================================Subroutines
# Given a file: find the name for both groups and store all the gene expression 
# each gene in hash. Return the groupnames and hash.
sub processFile {
	# Open the given file and initialize the variables
	my $tmpFile = $_[0];
#	print "tmpFile = $tmpFile\n";
	open( FILE, "<$tmpFile" ) or die "Cannot open $tmpFile for processing!\n";
	my @fileLines = grep /\S/, <FILE>;
	my ($group1Name, $group2Name, %fileHash) = ();
	
	for ( my $i = 0 ; $i <= $#fileLines ; $i++ ) {
		chomp( $fileLines[$i] );
		my @tmpArray = split( '\t', $fileLines[$i] );
		if ( $i == 0 ) {
			$group1Name = substr( $tmpArray[1], 3, 1 );
			$group2Name = substr( $tmpArray[2], 3, 1 );
		}
		else {
			if ( !defined @fileHash{ $tmpArray[0] } ) {
				$fileHash{ $tmpArray[0] } = $tmpArray[1]."\t".$tmpArray[2];
			}
			else {
				die "Duplicate gene in the input file, $tmpFile\n!";
			}
		}

	}
	
#	foreach my $gene (keys %fileHash) {
#		print "gene = $gene, value = $fileHash{$gene}\n";
#	}
	return ($group1Name, $group2Name, \%fileHash);
}

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